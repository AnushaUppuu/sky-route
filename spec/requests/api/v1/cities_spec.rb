require 'rails_helper'

RSpec.describe "Api::V1::Cities", type: :request do
  describe "Tests related to the GET /api/v1/cities route" do
    let(:endpoint) { "/api/v1/cities" }

    context "when there are cities in the database" do
      let!(:city1) { City.create!(name: "Bangalore") }
      let!(:city2) { City.create!(name: "Chennai") }

      it "returns a list of cities with id and name" do
        get endpoint
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key("cities")
        expect(json["cities"]).to be_an(Array)
        city_names = json["cities"].map { |c| c["name"] }
        expect(city_names).to include("Bangalore", "Chennai")
        json["cities"].each do |city|
          expect(city).to have_key("id")
          expect(city).to have_key("name")
        end
      end
    end

    context "when there are no cities in the database" do
      it "returns an empty array" do
        get endpoint
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to eq({ "cities" => [] })
      end
    end
  end
end
