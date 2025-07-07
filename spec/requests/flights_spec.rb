# spec/requests/flights_spec.rb
require 'rails_helper'

RSpec.describe "FlightsController", type: :request do
  let(:file_path) { Rails.root.join('data', 'test.txt') }
  let(:flights_data) do
    [
      { "id" => 1, "flight_number" => "AI101", "source" => "Delhi", "destination" => "Mumbai", "price" => 4500 },
      { "id" => 2, "flight_number" => "AI102", "source" => "Chennai", "destination" => "Bangalore", "price" => 3500 }
    ]
  end

  before do
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, JSON.pretty_generate(flights_data))
  end





  describe "POST /flights/update" do
    it "updates flight data" do
      post "/flights/update"
      updated_flights = JSON.parse(File.read(file_path))
      expect(updated_flights.first["price"]).to eq(4500)
    end
  end

  describe "GET /flights/search" do
    it "returns search results matching origin and destination" do
      get "/flights/search", params: { query: "Mumbai", origin: "Delhi" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("AI101")
      expect(response.body).not_to include("AI102")
    end

    it "redirects with alert if params are missing" do
      get "/flights/search", params: { query: "", origin: "" }
      expect(response).to redirect_to(root_path)
      follow_redirect!
    end
  end
end
