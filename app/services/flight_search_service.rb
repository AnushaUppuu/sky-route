class FlightSearchService
  attr_reader :params, :errors, :status

  def initialize(params)
    @params = params
    @status = :ok
  end

  def validate_params
    if source.blank? || destination.blank?
      @status = :bad_request
      return error("Source and destination are required")
    end

    if source == destination
      @status = :bad_request
      return error("Source and destination cannot be the same")
    end

    unless valid_departure_date?
      @status = :bad_request
      return error("Invalid departure date")
    end

    unless source_airport && destination_airport
      @status = :bad_request
      return error("Invalid source or destination airport")
    end

    unless selected_class_id
      @status = :bad_request
      return error("Invalid class type")
    end

    nil
  end

  def fetch_flights
    flights = Flight.where(source_airport_id: source_airport.id, destination_airport_id: destination_airport.id)
    if flights.blank?
      @status = :not_found
      return error("No flights between the selected route")
    end
    flights
  end

  def filter_by_recurrence(flights)
    available = flights.select do |flight|
      recurrence = flight.recurrence
      next false unless recurrence

      case recurrence.recurrence_type.downcase
      when "daily"
        true
      when "weekly"
        weekdays = FlightWeekday.where(flight_id: flight.id)
        weekdays.any? { |fw| fw.day_of_week.downcase == departure_date.strftime("%A").downcase }
      when "special"
        FlightSpecialDate.exists?(flight_id: flight.id, special_date: departure_date)
      when "custom"
        FlightCustomDate.exists?(flight_id: flight.id, custom_date: departure_date)
      else
        false
      end
    end

    if available.blank?
      @status = :not_found
      return error("No flights available on the selected date")
    end

    available
  end

  def filter_by_seats_and_class(flights)
    schedules = FlightSchedule.where(flight_id: flights.map(&:id))
    if schedules.blank?
      @status = :not_found
      return error("No flight schedules available on the selected date")
    end
    available = flights.map do |flight|
      schedule = schedules.find { |fs| fs.flight_id == flight.id }
      next unless schedule

      flight_seat = FlightSeat.find_by(flight_schedule_id: schedule.id, flight_class_id: selected_class_id)
      next unless flight_seat && flight_seat.available_seats >= passengers

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
          params[:departure_date]
        ),
        total_seats: flight_seat.total_seats,
        available_seats: flight_seat.available_seats,
        currency: currency,
        class_type: class_type,
        recurrence: flight.recurrence,
        airlines: find_airline(flight.airline_id),
        source_airport: source_airport.name,
        destination_airport: destination_airport.name,
        source_airport_city: source_airport.city,
        destination_airport_city: destination_airport.city,
        passengers: passengers,
        departure_date: params[:departure_date]
      }
    end.compact

    if available.blank?
      @status = :not_found
      return error("No flights available for #{passengers} travelers")
    end

    available
  end

  private

  def error(message)
    { error: message }
  end

  def source         = params[:source]
  def destination    = params[:destination]
  def class_type     = (params[:class_type]&.downcase || "economy")
  def currency       = (params[:currency]&.upcase || "INR")
  def passengers     = (params[:passengers]&.to_i || 1)

  def departure_date
    @departure_date ||= begin
      Date.parse(params[:departure_date])
    rescue
      nil
    end
  end

  def valid_departure_date?
    departure_date.present?
  end

  def source_airport      = @source_airport ||= Airport.find_by(code: source)
  def destination_airport = @destination_airport ||= Airport.find_by(code: destination)
  def selected_class_id   = @selected_class_id ||= FlightClass.find_by(name: class_type.capitalize)&.id

  def calculate_total_fare(total_seats, available_seats, price, passengers, departure_date)
    price.to_f * passengers
  end

  def find_airline(airline_id)
    Airline.find_by(id: airline_id)&.name
  end
end
