module Api
  module V1
    class CitiesController < ApplicationController
      def index
        cities = City.select(:id, :name).order(:name)
        render json: { cities: cities }, status: :ok
      end
    end
  end
end
