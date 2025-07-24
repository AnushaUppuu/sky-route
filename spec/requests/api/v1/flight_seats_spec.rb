require 'rails_helper'

RSpec.describe "FlightSeatsController", type: :request do
  describe "Tests realted to the POST /api/v1/flight_seats/update_count route" do
    before(:each) do
      @airline = Airline.create!(name: "AirTest", code: "AT")
      @source_airport = Airport.create!(name: "Source Airport", code: "SRC", city: "CityA", country: "CountryA")
      @destination_airport = Airport.create!(name: "Dest Airport", code: "DST", city: "CityB", country: "CountryB")
      @recurrence = Recurrence.create!(recurrence_type: "Daily")

      @flight = Flight.create!(
        flight_number: "AI123",
        airline_id: @airline.id,
        source_airport_id: @source_airport.id,
        destination_airport_id: @destination_airport.id,
        recurrence_id: @recurrence.id
      )

      @schedule = FlightSchedule.create!(
        flight_id: @flight.id,
        departure_time: "10:00",
        arrival_time: "12:00",
        status: "On Time"
      )

      @flight_class = FlightClass.create!(name: "Economy")

      @seat = FlightSeat.create!(
        flight_schedule_id: @schedule.id,
        flight_class_id: @flight_class.id,
        total_seats: 50,
        available_seats: 10,
        price: 100.0
      )
    end

    let(:valid_params) do
      {
        flight_number: @flight.flight_number,
        class_type: "economy",
        passengers: 3
      }
    end

    it "Should book successfully and should reduce available seats" do
      post "/api/v1/flight_seats/update_count", params: valid_params

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Booking Successful")
      expect(@seat.reload.available_seats).to eq(7)
    end

    it "Should return error if flight_number is missing" do
      post "/api/v1/flight_seats/update_count", params: valid_params.merge(flight_number: nil)

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Invalid booking details")
    end

    it "Should return error if class_type is missing" do
      post "/api/v1/flight_seats/update_count", params: valid_params.merge(class_type: nil)

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Invalid booking details")
    end

    it "Should return error if passengers count is zero" do
      post "/api/v1/flight_seats/update_count", params: valid_params.merge(passengers: 0)

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Invalid booking details")
    end

    it "Should return error if flight not found" do
      post "/api/v1/flight_seats/update_count", params: valid_params.merge(flight_number: "UNKNOWN")

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Flight not found")
    end

    it "Should return error if schedule not found" do
        @seat.destroy
        @schedule.destroy

        post "/api/v1/flight_seats/update_count", params: valid_params

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Flight schedule not found")
    end

    it "Should return error if class type is invalid" do
      post "/api/v1/flight_seats/update_count", params: valid_params.merge(class_type: "luxury")

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Invalid class type")
    end

    it "Should return error if seat not found for that class" do
      @seat.destroy

      post "/api/v1/flight_seats/update_count", params: valid_params

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Given class is not available for the flight")
    end

    it "Should return error if enough seats are not available" do
      @seat.update!(available_seats: 2)

      post "/api/v1/flight_seats/update_count", params: valid_params.merge(passengers: 5)

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Not enough seats available")
    end
  end
end
