require 'rails_helper'
require 'csv'

RSpec.describe "FlightsController", type: :request do
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
      },
      {
        "airlines" => "AirIndia",
        "flight_number" => "AI102",
        "source" => "Chennai",
        "destination" => "Bangalore",
        "economy_base_price" => "3500",
        "first_class_base_price" => "8500",
        "second_class_base_price" => "6500",
        "economy_total_seats" => "100",
        "first_class_total_seats" => "20",
        "second_class_total_seats" => "30",
        "economy_available_seats" => "0",
        "first_class_available_seats" => "0",
        "second_class_available_seats" => "15",
        "departure_date" => "2025-07-21",
        "departure_time" => "14:00",
        "arrival_date" => "2025-07-21",
        "arrival_time" => "16:00"
      },
      {
        "airlines" => "Vistara",
        "flight_number" => "VI103",
        "source" => "Delhi",
        "destination" => "Mumbai",
        "economy_base_price" => "4800",
        "first_class_base_price" => "9200",
        "second_class_base_price" => "7200",
        "economy_total_seats" => "100",
        "first_class_total_seats" => "20",
        "second_class_total_seats" => "30",
        "economy_available_seats" => "8",
        "first_class_available_seats" => "0", # No first class seats
        "second_class_available_seats" => "20",
        "departure_date" => "2025-07-20",
        "departure_time" => "15:00",
        "arrival_date" => "2025-07-20",
        "arrival_time" => "17:00"
      }
    ]
  end

  before do
    FileUtils.mkdir_p(File.dirname(file_path))
    CSV.open(file_path, "w") do |csv|
      csv << flights_data.first.keys
      flights_data.each { |row| csv << row.values }
    end
    stub_const("FlightsController::FILE_PATH", file_path)
  end

  describe "Tests related to the route GET /flights/search and corresponding view" do
    it "renders the search template successfully" do
      get "/flights/search"
      expect(response).to have_http_status(:ok)
      expect(response.body).to match("Find your ticket Now 🛫")
      expect(response.body).to include("From")
      expect(response.body).to include("To")
      expect(response.body).to include("Departure Date")
      expect(response.body).to include("Class Type")
      expect(response.body).to include("Search")
    end
  end

  describe "Tests related to the GET /flights/details route and corresponding view" do
    context "when searching with Economy class and matching fields" do
      it "returns flights with available economy seats and correct display price" do
        get "/flights/details", params: {
          source: "Delhi",
          destination: "Mumbai",
          departure_date: "2025-07-20",
          class_type: "Economy"
        }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("AI101")
        expect(response.body).to include("4500")
        expect(response.body).to include("VI103")
        expect(response.body).to include("4800")
      end
    end

    context "when searching with First Class and available seats" do
      it "returns flights with available first class seats and correct display price" do
        get "/flights/details", params: {
          source: "Delhi",
          destination: "Mumbai",
          departure_date: "2025-07-20",
          class_type: "First Class"
        }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("AI101")
        expect(response.body).to include("9000")
        expect(response.body).not_to include("VI103")
      end
    end

    context "when searching with First Class and no available seats" do
      it "returns no results when no first class seats are available" do
        get "/flights/details", params: {
          source: "Chennai",
          destination: "Bangalore",
          departure_date: "2025-07-21",
          class_type: "First Class"
        }
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("AI102")
        expect(response.body).to include("No flights were available for your search")
      end
    end

    context "when searching with Second Class and available seats" do
      it "returns flights with available second class seats and correct display price" do
        get "/flights/details", params: {
          source: "Delhi",
          destination: "Mumbai",
          departure_date: "2025-07-20",
          class_type: "Second Class"
        }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("AI101")
        expect(response.body).to include("7000")
        expect(response.body).to include("VI103")
        expect(response.body).to include("7200")
      end
    end

    context "when no flights match the search criteria" do
      it "returns an empty @search_results and shows no flights message" do
        get "/flights/details", params: {
          source: "Warangal",
          destination: "Karimnagar",
          departure_date: "2025-07-25",
          class_type: "Economy"
        }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("No flights were available for your search")
        expect(response.body).not_to include("AI101")
        expect(response.body).not_to include("VI103")
      end
    end

    context "when misses the required params" do
      it "redirects back to search with an alert when source is missing" do
        get "/flights/details", params: {
          destination: "Karimnagar",
          departure_date: "2025-07-25",
          class_type: "Economy"
        }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(search_flights_path)
        follow_redirect!
        expect(response.body).to include("Select both the source and destination cities")
      end
    end
    context "when source and destination are the same" do
      it "redirects back to the search page with an alert" do
        get "/flights/details", params: {
          source: "Delhi",
          destination: "Delhi",
          departure_date: "2025-07-20",
          class_type: "Economy"
        }

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(search_flights_path)

        follow_redirect!

        expect(response.body).to include("Source and destination cannot be the same.")
      end
    end
  end
end
