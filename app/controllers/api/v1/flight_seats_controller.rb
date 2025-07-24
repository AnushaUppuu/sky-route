module Api
  module V1
    class FlightSeatsController < ApplicationController
      def update_count
        flight_number, class_type, passengers = extract_booking_params

        return render json: { error: "Invalid booking details" }, status: :bad_request if flight_number.blank? || class_type.blank? || passengers <= 0

        flight = Flight.find_by(flight_number: flight_number)
        return render json: { error: "Flight not found" }, status: :not_found unless flight

        schedule = FlightSchedule.find_by(flight_id: flight.id)
        return render json: { error: "Flight schedule not found" }, status: :not_found unless schedule

        flight_class = FlightClass.find_by("LOWER(name) = ?", class_type.downcase)
        return render json: { error: "Invalid class type" }, status: :bad_request unless flight_class

        seat = FlightSeat.find_by(flight_schedule_id: schedule.id, flight_class_id: flight_class.id)
        return render json: { error: "Given class is not available for the flight" }, status: :not_found unless seat

        FlightSeat.transaction do
          seat.lock!
          if seat.available_seats >= passengers
            seat.update!(available_seats: seat.available_seats - passengers)
            return render json: { message: "Booking Successful" }, status: :ok
          else
            return render json: { error: "Not enough seats available" }, status: :unprocessable_entity
          end
        end
      end

      private
      def extract_booking_params
        permitted = params.permit(:flight_number, :class_type, :passengers)
        [ permitted[:flight_number], permitted[:class_type]&.strip, permitted[:passengers].to_i ]
      end
    end
  end
end
