require 'rails_helper'
require 'csv'

RSpec.describe "FlightsController", type: :request do
  let(:file_path) { Rails.root.join('data', 'test.txt') }
  let(:flights_data) do
    [
      { "id" => 1, "flight_number" => "AI101", "source" => "Delhi", "destination" => "Mumbai", "economy_base_price" => 4500, "departure_date" => "2024-05-01" },
      { "id" => 2, "flight_number" => "AI102", "source" => "Chennai", "destination" => "Bangalore", "economy_base_price" => 3500, "departure_date" => "2024-05-02" }
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

  describe "GET /flights/details" do
    it "returns search results matching all fields" do
      get "/flights/details", params: { destination: "Mumbai", source: "Delhi", departure_date: "2024-05-01" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("AI101")
      expect(response.body).to include("Delhi")
      expect(response.body).to include("Mumbai")
      expect(response.body).to include("2024-05-01")
      expect(response.body).to include("4500")
      expect(response.body).not_to include("AI102")
    end
  end
end
