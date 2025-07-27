module Api
  module V1
    class FlightsController < ApplicationController
      include FlightsHelper
       def search
          permitted = params.permit(
            :source, :destination, :departure_date, :passengers, :class_type,
            :currency, :trip_type, :return_date
          )
          service = FlightSearchService.new(permitted)

          unless service.valid?
            return render json: service.errors, status: service.status
          end

          flights = service.fetch_flights
          return render json: flights, status: service.status if flights.is_a?(Hash) # error

          if permitted[:trip_type].to_s.downcase == "round_trip"
            onward_flights = service.filter_flights_by_date_recurrence(flights[:onward_flights], service.send(:departure_date))
            return render json: onward_flights, status: service.status if onward_flights.is_a?(Hash)

            return_flights = service.filter_flights_by_date_recurrence(flights[:return_flights], service.send(:return_date))
            return render json: return_flights, status: service.status if return_flights.is_a?(Hash)

            final_onward = service.filter_available_schedules(onward_flights, service.send(:departure_date))
            return render json: final_onward, status: service.status if final_onward.is_a?(Hash)

            final_return = service.filter_available_schedules(return_flights, service.send(:return_date))
            return render json: final_return, status: service.status if final_return.is_a?(Hash)

            return render json: {
              onward_flights: final_onward,
              return_flights: final_return
            }, status: :ok
          end

            available = service.filter_flights_by_date_recurrence(flights, service.send(:departure_date))
            return render json: available, status: service.status if available.is_a?(Hash)

            final_flights = service.filter_available_schedules(available, service.send(:departure_date))
            return render json: final_flights, status: service.status if final_flights.is_a?(Hash)

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
