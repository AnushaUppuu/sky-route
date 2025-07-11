require 'rails_helper'
require 'csv'

RSpec.describe "Api::V1::FlightsController", type: :request do
  let(:file_path) { Rails.root.join('data', 'test.txt') }
  let(:flights_data) do
    [
      {
        "airlines" => "AirIndia",
        "flight_number" => "AI101",
        "source" => "Delhi",
        "destination" => "Mumbai",
        "economy_base_price" => "4500",
        "first_class_base_price" => "9000",
        "second_class_base_price" => "7000",
        "economy_total_seats" => "100",
        "first_class_total_seats" => "20",
        "second_class_total_seats" => "30",
        "economy_available_seats" => "5",
        "first_class_available_seats" => "10",
        "second_class_available_seats" => "15",
        "departure_date" => "2025-07-20",
        "departure_time" => "10:00",
        "arrival_date" => "2025-07-20",
        "arrival_time" => "12:00"
      }
    ]
  end

  before do
    FileUtils.mkdir_p(File.dirname(file_path))
    CSV.open(file_path, "w") do |csv|
      csv << flights_data.first.keys
      flights_data.each { |row| csv << row.values }
    end
    stub_const("Api::V1::FlightsController::FILE_PATH", file_path)
  end

  describe "Tests related to the route GET /api/v1/flights" do
    it "should returns all flights" do
      get "/api/v1/flights"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]).to be_an(Array)
      expect(body["message"]).to eq("Flights fetched successfully")
    end
  end

  describe "Test related to the route GET /api/v1/flights/search" do
    it "should returns a list of unique cities" do
      get "/api/v1/flights/search"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]).to be_an(Array)
      expect(body["message"]).to eq("Available cities fetched successfully")
    end
  end

  describe "Tests related to the route PATCH /api/v1/flights/update_seat_count" do
    it "should books seats if available" do
      patch "/api/v1/flights/update_seat_count", params: {
        flight_number: "AI101",
        class_type: "economy",
        passengers: 2
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Booking successful")
    end

    it "should returns error if not enough seats" do
      patch "/api/v1/flights/update_seat_count", params: {
        flight_number: "AI101",
        class_type: "economy",
        passengers: 1000
      }
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Not enough seats available")
    end

    it "should returns error if invalid parameters" do
      patch "/api/v1/flights/update_seat_count", params: { flight_number: "", class_type: "economy", passengers: 1 }
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Invalid booking details")
    end

    it "should returns error if flight number not found while updating seats" do
      patch "/api/v1/flights/update_seat_count", params: {
        flight_number: "INVALID123",
        class_type: "economy",
        passengers: 1
      }
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Flight not found for updating seats")
    end
  end

  describe "Tests related to the route GET /api/v1/flights/details" do
    it "should returns matching flights when valid params are provided" do
      get "/api/v1/flights/details", params: {
        source: "Delhi",
        destination: "Mumbai",
        departure_date: "2025-07-20",
        class_type: "Economy"
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]).to be_an(Array)
      expect(body["message"]).to eq("Flights matching your criteria")
    end

    it "should returns error when source and destination are the same" do
      get "/api/v1/flights/details", params: {
        source: "Delhi",
        destination: "Delhi"
      }
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Source and destination cannot be the same")
    end

    it "should returns error when no flights found" do
      get "/api/v1/flights/details", params: {
        source: "Warangal",
        destination: "Karimnagar"
      }
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("No flights found for this source and destination")
    end

    it "should returns error when params are missing" do
      get "/api/v1/flights/details", params: { destination: "Mumbai" }
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Source and destination are required")
    end

    it "should returns error if no flights available with the given criteria" do
      get "/api/v1/flights/details", params: {
        source: "Delhi",
        destination: "Mumbai",
        departure_date: "2025-07-20",
        passengers: 10,
        class_type: "Economy"
      }
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("No flights available with the given criteria")
    end

    it "should calculates price using first class base price when class_type is 'first class'" do
      get "/api/v1/flights/details", params: {
        source: "Delhi",
        destination: "Mumbai",
        departure_date: "2025-07-20",
        passengers: 1,
        class_type: "first class"
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"].first["class_type"]).to eq("first class")
      expect(body["message"]).to eq("Flights matching your criteria")
    end

    it "should calculates price using second class base price when class_type is 'second class'" do
      get "/api/v1/flights/details", params: {
        source: "Delhi",
        destination: "Mumbai",
        departure_date: "2025-07-20",
        passengers: 1,
        class_type: "second class"
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"].first["class_type"]).to eq("second class")
    end
  end
end
