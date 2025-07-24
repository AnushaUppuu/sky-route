module Api
  module V1
    class FlightsController < ApplicationController
      include FlightsHelper
         def search
              permitted = params.permit(:source, :destination, :departure_date, :passengers, :class_type, :currency)
              service = FlightSearchService.new(permitted)

              unless service.valid?
                return render json: service.errors, status: service.status
              end

              flights = service.fetch_flights
              return render json: flights, status: service.status if flights.is_a?(Hash) # error

              available = service.filter_flights_by_date_recurrence(flights)
              return render json: available, status: service.status if available.is_a?(Hash) # error

              final_flights = service.filter_available_schedules(available)
              return render json: final_flights, status: service.status if final_flights.is_a?(Hash) # error

              render json: final_flights, status: :ok
        end
        def update_count
          service = BookingService.new(params)
          result = service.process_booking

          if result
            render json: result, status: :ok
          else
            render json: service.error_message, status: service.status
          end
       end
    end
  end
end
