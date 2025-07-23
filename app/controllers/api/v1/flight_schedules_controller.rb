module Api
  module V1
    class FlightSchedulesController < ApplicationController
        include FlightsHelper
        def search
            permitted_params = params.permit(:source, :destination, :departure_date, :passengers, :class_type, :currency)
            if permitted_params[:source] == permitted_params[:destination]
                return render json: { error: "Source and destination cannot be the same" }, status: :bad_request
            end
            unless permitted_params[:source].present? && permitted_params[:destination].present?
                return render json: { error: "Source and destination are required" }, status: :bad_request
            end
            passengers = permitted_params[:passengers].present? ? permitted_params[:passengers].to_i : 1
            class_type = permitted_params[:class_type]&.downcase || "economy"
            currency = permitted_params[:currency]&.upcase || "INR"
            begin
                departure_date = Date.parse(permitted_params[:departure_date])
            rescue
                return render json: { error: "Invalid departure date" }, status: :bad_request
            end
            source_airport = Airport.find_by(code: permitted_params[:source])
            destination_airport = Airport.find_by(code: permitted_params[:destination])
            unless source_airport && destination_airport
                return render json: { error: "Invalid source or destination airport" }, status: :bad_request
            end
            selected_class_id = FlightClass.find_by(name: class_type.capitalize())&.id
            if selected_class_id.nil?
                return render json: { error: "Invalid class type" }, status: :bad_request
            end
            flights = Flight.where(source_airport_id: source_airport.id, destination_airport_id: destination_airport.id)
            if flights.blank?
                return render json: { error: "No flights between the selected route" }, status: :not_found
            end
            available_flights = []
            flights.each do |flight|
                recurrence = flight.recurrence
                next if recurrence.nil?
                recurrence_type = recurrence.recurrence_type.downcase
                case recurrence_type
                when "daily"
                    available_flights << flight
                when "weekly"

                        weekdays = FlightWeekday.where(flight_id: flight.id)
                        day_name = departure_date.strftime("%A").downcase

                        if weekdays.any? { |fw| fw.day_of_week.downcase == day_name }
                            available_flights << flight
                        end
                when "special"
                        specials = FlightSpecialDate.where(flight_id: flight.id)
                        if specials.any? { |sd| sd.special_date == departure_date }
                            available_flights << flight
                        end
                when "custom"
                        customs = FlightCustomDate.where(flight_id: flight.id)
                        if customs.any? { |cd| cd.custom_date == departure_date }
                            available_flights << flight
                        end
                end
            end
            if available_flights.empty?
                return render json: { error: "No flights available on the selected date" }, status: :not_found
            end
            flight_schedules = FlightSchedule.where(flight_id: available_flights.map(&:id))
            if flight_schedules.empty?
                return render json: { error: "No flight schedules available on the selected date" }, status: :not_found
            end
            available_flights = available_flights.map do |flight|
                schedule = flight_schedules.find { |fs| fs.flight_id == flight.id }
                next unless schedule
                flight_seat = FlightSeat.find_by(flight_schedule_id: schedule.id, flight_class_id: selected_class_id)
                next unless flight_seat
                if flight_seat.available_seats >= passengers
                    {
                        id: flight.id,
                        flight_number: flight.flight_number,
                        departure_time: schedule.departure_time,
                        arrival_time: schedule.arrival_time,
                        base_price: flight_seat.price,
                        total_cost: calculate_total_fare(
                            flight_seat.total_seats,
                            flight_seat.available_seats,
                            flight_seat.price,
                            passengers,
                            permitted_params[:departure_date]
                        ),
                        total_seats: flight_seat.total_seats,
                        available_seats: flight_seat.available_seats,
                        currency: currency,
                        class_type: class_type,
                        recurrence: flight.recurrence,
                        source_airport: {
                            code: source_airport.code,
                            name: source_airport.name,
                            city: source_airport.city
                        },
                        destination_airport: {
                            code: destination_airport.code,
                            name: destination_airport.name,
                            city: destination_airport.city
                        }
                    }
                end
            end.compact
            if available_flights.empty?
                return render json: { error: "No flights available for #{passengers} travelers" }, status: :not_found
            end
           render json: available_flights
        end
    end
  end
end
