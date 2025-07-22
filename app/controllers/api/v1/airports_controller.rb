module Api
  module V1
    class AirportsController < ApplicationController
      def index
        airports = Airport.select(:name, :code, :city, :country).order(:name)

        render json: {
          airports: airports.map { |airport|
            {
              name: airport.name,
              code: airport.code,
              city: airport.city,
              country: airport.country
            }
          }
        }, status: :ok
      end
    end
  end
end
