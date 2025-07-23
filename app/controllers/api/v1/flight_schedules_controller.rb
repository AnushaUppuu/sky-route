module Api
  module V1
    class FlightSchedulesController < ApplicationController
      include FlightsHelper
        def search
            permitted = params.permit(:source, :destination, :departure_date, :passengers, :class_type, :currency)
            service = FlightSearchService.new(permitted)

            if (error = service.validate_params)
                return render json: error, status: service.status
            end

            flights = service.fetch_flights
            return render json: flights, status: service.status if flights.is_a?(Hash) # error

            available = service.filter_by_recurrence(flights)
            return render json: available, status: service.status if available.is_a?(Hash) # error

            final_flights = service.filter_by_seats_and_class(available)
            return render json: final_flights, status: service.status if final_flights.is_a?(Hash) # error

            render json: final_flights, status: :ok
        end
    end
  end
end
