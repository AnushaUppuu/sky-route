require 'rails_helper'

RSpec.describe "Api::V1::FlightsController", type: :request do
  describe "POST /api/v1/flights/search" do
    let!(:source_airport) { Airport.create!(code: "DEL", name: "Delhi Airport", city: "Delhi") }
    let!(:destination_airport) { Airport.create!(code: "BOM", name: "Mumbai Airport", city: "Mumbai") }
    let!(:airline) { Airline.create!(name: "Air India", code: "AI") }
    let!(:recurrence) { Recurrence.create!(recurrence_type: "daily") }
    let!(:flight_class) { FlightClass.create!(name: "Economy") }

    let!(:flight) do
      Flight.create!(
        flight_number: "AI123",
        source_airport: source_airport,
        destination_airport: destination_airport,
        airline: airline,
        recurrence: recurrence
      )
    end

    let!(:flight_schedule) do
      FlightSchedule.create!(
        flight: flight,
        departure_time: Time.now + 1.day,
        arrival_time: Time.now + 1.day + 2.hours,
        status: "On Time"
      )
    end

    let!(:flight_seat) do
      FlightSeat.create!(
        flight_schedule: flight_schedule,
        flight_class: flight_class,
        total_seats: 100,
        price: 5000
      )
    end
    def set_seat_availability(seat, date:, available_seats:)
      availability = FlightSeatAvailability.find_or_initialize_by(flight_seat: seat, scheduled_date: date)
      availability.available_seats = available_seats
      availability.save!
    end

    context "when flights are available" do
      before do
        set_seat_availability(flight_seat, date: Date.today, available_seats: 10)
      end

      it "returns available flights with total cost (one way)" do
        post "/api/v1/flights/search", params: {
          source: "DEL",
          destination: "BOM",
          departure_date: Date.today.to_s,
          passengers: 1,
          class_type: "Economy",
          currency: "INR"
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        expect(json.first).to have_key("total_cost")
      end

      it "returns available flights for round trip with onward and return keys" do
        return_flight = Flight.create!(
          flight_number: "AI124",
          source_airport: destination_airport,
          destination_airport: source_airport,
          airline: airline,
          recurrence: recurrence
        )
        return_schedule = FlightSchedule.create!(
          flight: return_flight,
          departure_time: Time.now + 2.days,
          arrival_time: Time.now + 2.days + 2.hours,
          status: "On Time"
        )
        return_seat = FlightSeat.create!(
          flight_schedule: return_schedule,
          flight_class: flight_class,
          total_seats: 100,
          price: 5000
        )
        set_seat_availability(return_seat, date: Date.today + 1, available_seats: 10)

        post "/api/v1/flights/search", params: {
          source: "DEL",
          destination: "BOM",
          departure_date: Date.today.to_s,
          return_date: (Date.today + 1).to_s,
          passengers: 1,
          class_type: "Economy",
          currency: "INR",
          trip_type: "round_trip"
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to be_a(Hash)
        expect(json).to have_key("onward_flights")
        expect(json).to have_key("return_flights")
        expect(json["onward_flights"]).to be_an(Array)
        expect(json["return_flights"]).to be_an(Array)
        expect(json["onward_flights"].first).to have_key("total_cost")
        expect(json["return_flights"].first).to have_key("total_cost")
      end

      it "uses default values when class, passengers, or currency are missing" do
        post "/api/v1/flights/search", params: {
          source: "DEL",
          destination: "BOM",
          departure_date: Date.today.to_s
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.first["class_type"]).to eq("economy")
        expect(json.first["currency"]).to eq("INR")
      end
    end

    context "when input validation fails" do
      it "returns error when source and destination are the same" do
        post "/api/v1/flights/search", params: {
          source: "DEL",
          destination: "DEL",
          departure_date: Date.today.to_s,
          passengers: 1,
          class_type: "Economy",
          currency: "INR"
        }
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Source and destination cannot be the same")
      end

      it "returns error when source is missing" do
        post "/api/v1/flights/search", params: {
          destination: "BOM",
          departure_date: Date.today.to_s,
          passengers: 1,
          class_type: "Economy",
          currency: "INR"
        }
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Source and destination are required")
      end

      it "returns error when destination is missing" do
        post "/api/v1/flights/search", params: {
          source: "DEL",
          departure_date: Date.today.to_s,
          passengers: 1,
          class_type: "Economy",
          currency: "INR"
        }
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Source and destination are required")
      end

      it "returns error when departure date is invalid" do
        post "/api/v1/flights/search", params: {
          source: "DEL",
          destination: "BOM",
          departure_date: "not-a-date",
          passengers: 1,
          class_type: "Economy",
          currency: "INR"
        }
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid departure date")
      end

      it "returns error when source or destination airport code is invalid" do
        post "/api/v1/flights/search", params: {
          source: "XXX",
          destination: "BOM",
          departure_date: Date.today.to_s,
          passengers: 1,
          class_type: "Economy",
          currency: "INR"
        }
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid source or destination airport")
      end

      it "returns error when class type is invalid" do
        post "/api/v1/flights/search", params: {
          source: "DEL",
          destination: "BOM",
          departure_date: Date.today.to_s,
          passengers: 1,
          class_type: "InvalidClass",
          currency: "INR"
        }
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid class type")
      end
    end

    context "when flights or schedules are missing" do
      it "returns error when no flights exist between source and destination" do
        unknown_airport1 = Airport.create!(city: "Hyderabad", code: "ZZZ", name: "ZZZ Airport")
        unknown_airport2 = Airport.create!(city: "Delhi", code: "YYY", name: "YYY Airport")
        post "/api/v1/flights/search", params: {
          source: "ZZZ",
          destination: "YYY",
          departure_date: Date.today.to_s,
          passengers: 1,
          class_type: "Economy",
          currency: "INR"
        }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("No flights between the selected route")
      end

      it "returns error when no flights are available on the selected date" do
        flight.update!(recurrence: Recurrence.create!(recurrence_type: "weekly"))
        FlightWeekday.delete_all
        post "/api/v1/flights/search", params: {
          source: "DEL",
          destination: "BOM",
          departure_date: Date.today.to_s,
          passengers: 1,
          class_type: "Economy",
          currency: "INR"
        }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("No flights available on the selected date")
      end

      it "returns error when no flight schedules exist for matched flights" do
        FlightSeat.delete_all
        FlightSchedule.delete_all
        post "/api/v1/flights/search", params: {
          source: "DEL",
          destination: "BOM",
          departure_date: Date.today.to_s,
          passengers: 1,
          class_type: "Economy",
          currency: "INR"
        }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("No flight schedules available on the selected date")
      end
    end

    context "when seat availability is insufficient" do
      before do
        set_seat_availability(flight_seat, date: Date.today, available_seats: 0)
      end

      it "returns error when no seats available in selected class" do
        post "/api/v1/flights/search", params: {
          source: "DEL",
          destination: "BOM",
          departure_date: Date.today.to_s,
          passengers: 1,
          class_type: "Economy",
          currency: "INR"
        }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("No flights available for 1 travelers on #{Date.today}")
      end

      it "returns error when available seats are less than number of passengers" do
        set_seat_availability(flight_seat, date: Date.today, available_seats: 2)

        post "/api/v1/flights/search", params: {
          source: "DEL",
          destination: "BOM",
          departure_date: Date.today.to_s,
          passengers: 3,
          class_type: "Economy",
          currency: "INR"
        }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("No flights available for 3 travelers on #{Date.today}")
      end
    end
  end

  describe "Tests related to the POST /api/v1/flights/update_count route" do
    before(:each) do
      @airline = Airline.create!(name: "AirTest", code: "AT")
      @source_airport = Airport.create!(name: "Source Airport", code: "SRC", city: "CityA", country: "CountryA")
      @destination_airport = Airport.create!(name: "Dest Airport", code: "DST", city: "CityB", country: "CountryB")
      @recurrence = Recurrence.create!(recurrence_type: "Daily")

      @onward_flight = Flight.create!(
        flight_number: "AI123",
        airline_id: @airline.id,
        source_airport_id: @source_airport.id,
        destination_airport_id: @destination_airport.id,
        recurrence_id: @recurrence.id
      )
      @onward_schedule = FlightSchedule.create!(
        flight_id: @onward_flight.id,
        departure_time: "10:00",
        arrival_time: "12:00",
        status: "On Time"
      )
      @flight_class = FlightClass.create!(name: "Economy")
      @onward_seat = FlightSeat.create!(
        flight_schedule_id: @onward_schedule.id,
        flight_class_id: @flight_class.id,
        total_seats: 50,
        price: 100.0
      )
      @onward_availability = FlightSeatAvailability.create!(
        flight_seat_id: @onward_seat.id,
        scheduled_date: Date.today.to_s,
        available_seats: 10
      )

      @return_flight = Flight.create!(
        flight_number: "AI124",
        airline_id: @airline.id,
        source_airport_id: @destination_airport.id,
        destination_airport_id: @source_airport.id,
        recurrence_id: @recurrence.id
      )
      @return_schedule = FlightSchedule.create!(
        flight_id: @return_flight.id,
        departure_time: "16:00",
        arrival_time: "18:00",
        status: "On Time"
      )
      @return_seat = FlightSeat.create!(
        flight_schedule_id: @return_schedule.id,
        flight_class_id: @flight_class.id,
        total_seats: 50,
        price: 100.0
      )
      @return_availability = FlightSeatAvailability.create!(
        flight_seat_id: @return_seat.id,
        scheduled_date: (Date.today + 1).to_s,
        available_seats: 10
      )
    end

    let(:valid_params) do
      {
        flight_number: @onward_flight.flight_number,
        class_type: "economy",
        passengers: 3,
        scheduled_date: Date.today.to_s
      }
    end

    it "Should book successfully and reduce available seats for one way trip" do
      post "/api/v1/flights/update_count", params: valid_params

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Booking Successful")
      expect(@onward_availability.reload.available_seats).to eq(7)
    end

    it "Should book round trip successfully and reduce seats for both legs" do
      post "/api/v1/flights/update_count", params: {
        trip_type: "round_trip",
        onward: {
          flight_number: @onward_flight.flight_number,
          class_type: "economy",
          passengers: 2,
          scheduled_date: Date.today.to_s
        },
        return: {
          flight_number: @return_flight.flight_number,
          class_type: "economy",
          passengers: 2,
          scheduled_date: (Date.today + 1).to_s
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["onward"]["message"]).to eq("Booking Successful")
      expect(json["return"]["message"]).to eq("Booking Successful")
      expect(@onward_availability.reload.available_seats).to eq(8)
      expect(@return_availability.reload.available_seats).to eq(8)
    end

    it "Should fail round trip booking if return leg is invalid" do
      @return_availability.update!(available_seats: 1)

      post "/api/v1/flights/update_count", params: {
        trip_type: "round_trip",
        onward: {
          flight_number: @onward_flight.flight_number,
          class_type: "economy",
          passengers: 1002,
          scheduled_date: Date.today.to_s
        },
        return: {
          flight_number: @return_flight.flight_number,
          class_type: "economy",
          passengers: 1002,
          scheduled_date: (Date.today + 1).to_s
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["return"]["error"]).to eq("Not enough seats available")
      expect(@onward_availability.reload.available_seats).to eq(10)
      expect(@return_availability.reload.available_seats).to eq(1)
    end

    it "Should return error if flight_number is missing" do
      post "/api/v1/flights/update_count", params: valid_params.merge(flight_number: nil)
      expect(response).to have_http_status(:bad_request)
    end

    it "Should return error if class_type is missing" do
      post "/api/v1/flights/update_count", params: valid_params.merge(class_type: nil)
      expect(response).to have_http_status(:bad_request)
    end

    it "Should return error if passengers count is zero" do
      post "/api/v1/flights/update_count", params: valid_params.merge(passengers: 0)
      expect(response).to have_http_status(:bad_request)
    end

    it "Should return error if flight not found" do
      post "/api/v1/flights/update_count", params: valid_params.merge(flight_number: "UNKNOWN")
      expect(response).to have_http_status(:not_found)
    end

    it "Should return error if schedule not found" do
      @onward_schedule.destroy
      post "/api/v1/flights/update_count", params: valid_params
      expect(response).to have_http_status(:not_found)
    end

    it "Should return error if class type is invalid" do
      post "/api/v1/flights/update_count", params: valid_params.merge(class_type: "premium business")
      expect(response).to have_http_status(:bad_request)
    end

    it "Should return error if seat not found for that class" do
      @onward_seat.destroy
      post "/api/v1/flights/update_count", params: valid_params
      expect(response).to have_http_status(:not_found)
    end

    it "Should return error if not enough seats available" do
      @onward_availability.update!(available_seats: 2)
      post "/api/v1/flights/update_count", params: valid_params.merge(passengers: 5)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
