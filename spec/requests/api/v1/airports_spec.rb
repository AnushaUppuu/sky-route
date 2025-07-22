require 'rails_helper'

RSpec.describe 'Api::V1::Airports', type: :request do
    # Create a few sample airports
    let!(:source_airport) { Airport.create!(name: 'Bangalore Airport', code: 'BLR', city: 'Bangalore', country: 'India') }
    let!(:destination_airport) { Airport.create!(name: 'Mumbai Airport', code: 'BOM', city: 'Mumbai', country: 'India') }
  describe 'Tests related to the GET /api/v1/airports route' do
    it 'Should returns a list of airports ordered by name' do
      get '/api/v1/airports'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['airports'].length).to eq(2)
      json['airports'].each do |airport|
        expect(airport.keys).to contain_exactly('name', 'code', 'city', 'country')
      end
      airport_names = json['airports'].map { |a| a['name'] }
      expect(airport_names).to eq(airport_names.sort)
    end
  end
end
