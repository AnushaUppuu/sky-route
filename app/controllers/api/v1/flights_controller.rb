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

        if permitted[:trip_type].to_s.parameterize.underscore == "round_trip"
          render_round_trip_flights(service, flights)
        else
          render_one_way_flights(service, flights)
        end
      end

      def update_count
        if params[:trip_type].to_s.parameterize.underscore == "round_trip"
          onward_service = BookingService.new(params[:onward])
          return_service = BookingService.new(params[:return])

          onward_result = onward_service.process_booking
          return_result = return_service.process_booking

          if onward_result && return_result
            render json: {
              onward: onward_result,
              return: return_result
            }, status: :ok
          else
            errors = {}
            errors[:onward] = onward_service.error_message unless onward_result
            errors[:return] = return_service.error_message unless return_result
            render json: errors, status: onward_service.status || return_service.status
          end
        else
          service = BookingService.new(params)
          result = service.process_booking

          if result
            render json: result, status: :ok
          else
            render json: service.error_message, status: service.status
          end
        end
      end

      private

      def render_round_trip_flights(service, flights)
        unless flights.is_a?(Hash) && flights.key?(:onward_flights) && flights.key?(:return_flights)
          return render json: { error: "No round-trip flights found" }, status: :not_found
        end

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


        if onward_final.blank? && return_final.blank?
          return render json: { error: "No flights available for the selected dates" }, status: :not_found
        end

        result = {
          onward_flights: onward_final,
          return_flights: return_final
        }
        result[:errors] = errors unless errors.empty?

        render json: result, status: :ok
      end

      def render_one_way_flights(service, flights)
        available = service.filter_flights_by_date_recurrence(flights, service.send(:departure_date))
        return render json: available, status: service.status if available.is_a?(Hash)

        final = service.filter_available_schedules(available, service.send(:departure_date))
        return render json: final, status: service.status if final.is_a?(Hash)

        render json: final, status: :ok
      end
    end
  end
end
