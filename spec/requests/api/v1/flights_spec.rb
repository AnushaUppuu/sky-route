require 'rails_helper'

RSpec.describe "Api::V1::FlightsController - details", type: :request do
  let!(:source_city) { City.create!(name: "Delhi") }
  let!(:destination_city) { City.create!(name: "Mumbai") }

  let!(:flight) do
    Flight.create!(
      airlines: "AirIndia",
      flight_number: "AI101",
      source_city: source_city,
      destination_city: destination_city,
      economy_base_price: 4500,
      first_class_base_price: 9000,
      second_class_base_price: 7000,
      economy_total_seats: 100,
      first_class_total_seats: 20,
      second_class_total_seats: 30,
      economy_available_seats: 5,
      first_class_available_seats: 10,
      second_class_available_seats: 15,
      departure_date: "2025-07-20",
      departure_time: "10:00",
      arrival_date: "2025-07-20",
      arrival_time: "12:00"
    )
  end

  describe "Tests related to the POST /api/v1/flights/details route" do
    it "Should returns matching flights with valid params" do
      post "/api/v1/flights/details", params: {
        source: "Delhi",
        destination: "Mumbai",
        departure_date: "2025-07-20",
        passengers: 1,
        class_type: "economy"
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]).to be_an(Array)
      expect(body["data"].first["flight_number"]).to eq("AI101")
      expect(body["message"]).to eq("Flights fetched successfully")
    end

    it "Should returns error when source and destination are the same" do
      post "/api/v1/flights/details", params: {
        source: "Delhi",
        destination: "Delhi"
      }
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Source and destination cannot be the same")
    end

    it "Should returns error when required params are missing" do
      post "/api/v1/flights/details", params: { destination: "Mumbai" }
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Source and destination are required")
    end

    it "Should returns error when no matching flights found" do
      post "/api/v1/flights/details", params: {
        source: "Hyderabad",
        destination: "Chennai"
      }
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid source or destination city")
    end

    it "Should returns error when not enough seats available for passengers" do
      post "/api/v1/flights/details", params: {
        source: "Delhi",
        destination: "Mumbai",
        departure_date: "2025-07-20",
        passengers: 100,
        class_type: "economy"
      }
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("No flights available on the selected date")
    end

    it "Should calculates price using first class base price when class_type is 'first class'" do
      post "/api/v1/flights/details", params: {
        source: "Delhi",
        destination: "Mumbai",
        departure_date: "2025-07-20",
        passengers: 1,
        class_type: "first class"
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"].first["class_type"]).to eq("first class")
      expect(body["data"].first["price_per_ticket"]).to eq(9000.0)
    end

    it "Should calculates price using second class base price when class_type is 'second class'" do
      post "/api/v1/flights/details", params: {
        source: "Delhi",
        destination: "Mumbai",
        departure_date: "2025-07-20",
        passengers: 1,
        class_type: "second class"
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"].first["class_type"]).to eq("second class")
      expect(body["data"].first["price_per_ticket"]).to eq(7000.0)
    end
  end

  describe "Tests related to the PATCH /api/v1/flights/update_seat_count count" do
    let(:endpoint) { "/api/v1/flights/update_seat_count" }

    it "Should book seats if available and reduces available count" do
      patch endpoint, params: {
        flight_number: "AI101",
        class_type: "economy",
        passengers: 2
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Booking successful")
      expect(flight.reload.economy_available_seats).to eq(3)
    end

    it "Should returns error if not enough seats" do
      patch endpoint, params: {
        flight_number: "AI101",
        class_type: "economy",
        passengers: 100
      }
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Not enough seats available")
    end

    it "Should returns error if flight is not found" do
      patch endpoint, params: {
        flight_number: "ABCD",
        class_type: "economy",
        passengers: 1
      }
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Flight not found for updating seats")
    end

    it "Should returns error if invalid class_type is provided" do
      patch endpoint, params: {
        flight_number: "AI101",
        class_type: "business",
        passengers: 1
      }
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid class type")
    end

    it "Should returns error if passengers param is missing or invalid" do
      patch endpoint, params: {
        flight_number: "AI101",
        class_type: "economy",
        passengers: 0
      }
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid booking details")
    end

    it "Should returns error if flight_number is missing" do
      patch endpoint, params: {
        flight_number: "",
        class_type: "economy",
        passengers: 1
      }
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid booking details")
    end
  end
end
