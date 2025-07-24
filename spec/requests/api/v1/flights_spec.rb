require 'rails_helper'

RSpec.describe "Api::V1::FlightsController", type: :request do
  describe "POST /api/v1/flights/search" do
    let!(:source_airport) { Airport.create!(code: "DEL", name: "Delhi Airport", city: "Delhi") }
    let!(:destination_airport) { Airport.create!(code: "BOM", name: "Mumbai Airport", city: "Mumbai") }
    let!(:airline) { Airline.create!(name: "Air India") }
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
        arrival_time: Time.now + 1.day + 2.hours
      )
    end

    let!(:flight_seat) do
      FlightSeat.create!(
        flight_schedule: flight_schedule,
        flight_class: flight_class,
        total_seats: 100,
        available_seats: 95,
        price: 5000
      )
    end

    it "Should returns available flights with total cost" do
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

    it "Should returns error when source and destination are the same" do
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

    it "Should returns error when source is missing" do
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

    it "should returns error when destination is missing" do
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

    it "Should returns error when departure date is invalid" do
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

    it "Should returns error when source or destination airport code is invalid" do
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

    it "Should returns error when class type is invalid" do
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

    it "Should returns error when no flights exist between source and destination" do
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

    it "Should returns error when no flights are available on the selected date" do
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

    it "Should returns error when no flight schedules exist for matched flights" do
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


    it "Should returns error when no seats available in selected class" do
        flight_seat.update!(available_seats: 0)
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
        expect(json["error"]).to eq("No flights available for 1 travelers")
    end

    it "Should returns error when available seats are less than number of passengers" do
        flight_seat.update!(available_seats: 2)
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
        expect(json["error"]).to eq("No flights available for 3 travelers")
    end

    it "Should uses default values when class, passengers, or currency are missing" do
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
end
