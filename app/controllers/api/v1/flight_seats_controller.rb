module Api
  module V1
    class FlightSeatsController < ApplicationController
        def update_count
            permitted_params = params.permit(:flight_number, :class_type, :passengers)

            flight_number = permitted_params[:flight_number]
            class_type = permitted_params[:class_type]&.downcase
            passengers = permitted_params[:passengers].to_i

            if flight_number.blank? || class_type.blank? || passengers <= 0
                return render json: { error: "Invalid booking details" }, status: :bad_request
            end

            flight = Flight.find_by(flight_number: flight_number)
            return render json: { error: "Flight not found" }, status: :not_found unless flight

            schedule = FlightSchedule.find_by(flight_id: flight.id)
            return render json: { error: "Flight schedule not found" }, status: :not_found unless schedule

            flight_class = FlightClass.find_by(name: class_type.capitalize())
            return render json: { error: "Invalid class type" }, status: :bad_request unless flight_class

            seat = FlightSeat.find_by(flight_schedule_id: schedule.id, flight_class_id: flight_class.id)
            return render json: { error: "Given class is not available for the flight" }, status: :not_found unless seat

            FlightSeat.transaction do
                seat.lock!
                if seat.available_seats >= passengers
                    seat.update!(available_seats: seat.available_seats - passengers)
                    return render json: {
                        message: "Booking Successful"
                    },
                    status: :ok
                end
                render json: { error: "Not enough seats available" },
                status: :unprocessable_entity
                raise ActiveRecord::Rollback
            end
        end
    end
  end
end
