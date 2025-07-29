class BookingService
  attr_reader :params, :status, :error_message

  def initialize(params)
    @params = params
    @status = :ok
    @error_message = nil
  end

  def process_booking
    flight_number, class_type, passengers, scheduled_date = extract_booking_params
    return error(:bad_request, "Invalid booking details") if flight_number.blank? || class_type.blank? || passengers <= 0 || scheduled_date.blank?

    flight = Flight.find_by(flight_number: flight_number)
    return error(:not_found, "Flight not found") unless flight

    schedule = FlightSchedule.find_by(flight_id: flight.id)
    return error(:not_found, "Flight schedule not found") unless schedule

    flight_class = FlightClass.find_by("LOWER(name) = ?", class_type.downcase)
    return error(:bad_request, "Invalid class type") unless flight_class

    seat = FlightSeat.find_by(flight_schedule_id: schedule.id, flight_class_id: flight_class.id)
    return error(:not_found, "Given class is not available for the flight") unless seat

    seat_availability = FlightSeatAvailability.find_by(flight_seat_id: seat.id, scheduled_date: scheduled_date)
    return error(:not_found, "No seat availability for the selected date") unless seat_availability

    FlightSeatAvailability.transaction do
      seat_availability.lock!
      if seat_availability.available_seats >= passengers
        seat_availability.update!(available_seats: seat_availability.available_seats - passengers)
        return { message: "Booking Successful" }
      else
        return error(:unprocessable_entity, "Not enough seats available")
      end
    end
  end

  private

  def error(status, message)
    @status = status
    @error_message = { error: message }
    nil
  end

  def extract_booking_params
    permitted = params.permit(:flight_number, :class_type, :passengers, :scheduled_date)
    [
      permitted[:flight_number],
      permitted[:class_type]&.strip,
      permitted[:passengers].to_i,
      permitted[:scheduled_date]
    ]
  end
end
