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
          puts "Flights fetched: #{flights.inspect}"
          puts "Trip Type: #{permitted[:trip_type].inspect}"

          if permitted[:trip_type].to_s.parameterize.underscore == "round_trip"
          puts "Round trip selected"

          errors = {}
          onward_final = []
          return_final = []

           onward = service.filter_flights_by_date_recurrence(flights[:onward_flights], service.send(:departure_date))
          if onward.is_a?(Hash)
            errors[:onward_flights] = onward[:error] || "Error filtering onward flights"
          else
            onward_final = service.filter_available_schedules(onward, service.send(:departure_date))
            if onward_final.is_a?(Hash)
              errors[:onward_flights] = onward_final[:error] || "No available onward flights"
              onward_final = []
            end
          end

          return_ = service.filter_flights_by_date_recurrence(flights[:return_flights], service.send(:return_date))
          if return_.is_a?(Hash)
            errors[:return_flights] = return_[:error] || "Error filtering return flights"
          else
            return_final = service.filter_available_schedules(return_, service.send(:return_date))
            if return_final.is_a?(Hash)
              errors[:return_flights] = return_final[:error] || "No available return flights"
              return_final = []
            end
          end

          result = {
            onward_flights: onward_final,
            return_flights: return_final
          }

          result[:errors] = errors unless errors.empty?

          return render json: result, status: :ok
          else
            available = service.filter_flights_by_date_recurrence(flights, service.send(:departure_date))
            return render json: available, status: service.status if available.is_a?(Hash)

            final = service.filter_available_schedules(available, service.send(:departure_date))
            return render json: final, status: service.status if final.is_a?(Hash)

            render json: final, status: :ok
          end
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
