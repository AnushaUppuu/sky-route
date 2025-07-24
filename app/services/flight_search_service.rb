class FlightSearchService
  attr_reader :params, :errors, :status

  def initialize(params)
    @params = params
    @status = :ok
  end

  def valid?
    return error!("Source and destination are required") if source.blank? || destination.blank?
    return error!("Source and destination cannot be the same") if source == destination
    return error!("Invalid departure date") unless departure_date_valid?
    return error!("Invalid source or destination airport") unless source_airport && destination_airport
    return error!("Invalid class type") unless selected_class_id
    true
  end

  def fetch_flights
    flights = Flight.where(source_airport_id: source_airport.id, destination_airport_id: destination_airport.id)
    return not_found("No flights between the selected route") if flights.blank?

    flights
  end

  def filter_flights_by_date_recurrence(flights)
    available = flights.select { |flight| flight_operates_on_date?(flight) }
    return not_found("No flights available on the selected date") if available.blank?

    available
  end

  def filter_available_schedules(flights)
    schedules_by_flight = FlightSchedule.where(flight_id: flights.map(&:id)).index_by(&:flight_id)
    return not_found("No flight schedules available on the selected date") if schedules_by_flight.blank?

    seats_by_schedule = FlightSeat.where(
      flight_schedule_id: schedules_by_flight.values.map(&:id),
      flight_class_id: selected_class_id
    ).index_by(&:flight_schedule_id)

    airlines_by_id = Airline.where(id: flights.map(&:airline_id).uniq).index_by(&:id)

    available = flights.map do |flight|
      schedule = schedules_by_flight[flight.id]
      seat = schedule && seats_by_schedule[schedule.id]
      next unless schedule && seat && seat.available_seats >= passengers

      build_flight_response(flight, schedule, seat, airlines_by_id[flight.airline_id])
    end.compact

    return not_found("No flights available for #{passengers} travelers") if available.blank?

    available
  end

  private

  def error!(message)
    @status = :bad_request
    @errors = { error: message }
    false
  end

  def not_found(message)
    @status = :not_found
    { error: message }
  end

  def build_flight_response(flight, schedule, seat, airline)
    {
      id: flight.id,
      flight_number: flight.flight_number,
      departure_time: schedule.departure_time,
      arrival_time: schedule.arrival_time,
      base_price: seat.price,
      total_cost: calculate_total_fare(seat.price, passengers),
      total_seats: seat.total_seats,
      available_seats: seat.available_seats,
      currency: currency,
      class_type: class_type,
      recurrence: flight.recurrence,
      airlines: airline&.name,
      source_airport: source_airport.name,
      destination_airport: destination_airport.name,
      source_airport_city: source_airport.city,
      destination_airport_city: destination_airport.city,
      passengers: passengers,
      departure_date: params[:departure_date]
    }
  end

  def flight_operates_on_date?(flight)
    recurrence = flight.recurrence
    return false unless recurrence

    case recurrence.recurrence_type.to_s.downcase
    when "daily"
      true
    when "weekly"
      weekdays = FlightWeekday.where(flight_id: flight.id)
      weekdays.any? { |fw| fw.day_of_week.to_s.downcase == departure_date.strftime("%A").downcase }
    when "special"
      FlightSpecialDate.exists?(flight_id: flight.id, special_date: departure_date)
    when "custom"
      FlightCustomDate.exists?(flight_id: flight.id, custom_date: departure_date)
    else
      false
    end
  end

  def departure_date_valid?
    departure_date.present?
  end

  def calculate_total_fare(price, passengers)
    price.to_f * passengers
  end

  # Memoized parameter accessors
  def source             = params[:source]
  def destination        = params[:destination]
  def class_type         = (params[:class_type]&.downcase || "economy")
  def currency           = (params[:currency]&.upcase || "INR")
  def passengers         = (params[:passengers]&.to_i || 1)

  def departure_date
    @departure_date ||= begin
      Date.parse(params[:departure_date])
    rescue
      nil
    end
  end

  def source_airport
    @source_airport ||= Airport.find_by(code: source)
  end

  def destination_airport
    @destination_airport ||= Airport.find_by(code: destination)
  end

  def selected_class_id
    @selected_class_id ||= FlightClass.find_by(name: class_type.capitalize)&.id
  end
end
