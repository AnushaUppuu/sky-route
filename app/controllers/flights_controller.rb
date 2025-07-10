require 'csv'

class FlightsController < ApplicationController
  include FlightsHelper
  FILE_PATH = Rails.root.join('data', 'data.txt')

  def index
  end

   def search
    @cities = load_unique_cities
    render :search
  end

  def load_flights_from_txt
    flights = []
    CSV.foreach(FILE_PATH, headers: true) do |row|
      flights << row.to_h.symbolize_keys
    end

    flights
  end

  def load_unique_cities
    flights = load_flights_from_txt
    sources = flights.map { |f| f[:source] }
    destinations = flights.map { |f| f[:destination] }
    (sources + destinations).uniq.compact.sort
  end

  def update_seat_count
    flight_number = params[:flight_number]
    class_type = params[:class_type]
    passengers = params[:passengers].to_i

    if flight_number.blank? || class_type.blank? || passengers <= 0
      flash[:alert] = "Invalid booking details."
      redirect_back(fallback_location: search_flights_path) and return
    end

    updated = false

    data = CSV.table(FILE_PATH, headers: true, converters: nil)

    data.each do |row|
      if row[:flight_number].to_s == flight_number.to_s
        available_key = "#{class_type.gsub(' ', '_')}_available_seats".to_sym
        current_seats = row[available_key].to_i
        if current_seats >= passengers
          row[available_key] = (current_seats - passengers).to_s
          updated = true
        else
          flash[:alert] = "Not enough seats available."
          redirect_back(fallback_location: search_flights_path) and return
        end
      end
    end

    if updated
      File.open(FILE_PATH, 'w') do |f|
        f.write(data.to_csv)
      end
      flash[:notice] = "Your Booking successful!"
    else
      flash[:alert] = "Flight not found for updating seats."
      redirect_back(fallback_location: search_flights_path) and return
    end
    redirect_to root_path
  end

  def details
    permitted_params = params.permit(:source, :destination, :departure_date, :passengers, :class_type)

    if permitted_params[:source].present? && permitted_params[:destination].present? &&
       permitted_params[:source] == permitted_params[:destination]
      redirect_to search_flights_path(permitted_params), alert: "Source and destination cannot be the same." and return
    end

    unless permitted_params[:source].present? && permitted_params[:destination].present?
      redirect_to search_flights_path(permitted_params), alert: "Select both the source and destination cities." and return
    end

    flights = load_flights_from_txt
    passengers = permitted_params[:passengers].present? ? permitted_params[:passengers].to_i : 1

    matching_flights = flights.select do |flight|
      flight[:source].downcase.include?(permitted_params[:source].downcase) &&
      flight[:destination].downcase.include?(permitted_params[:destination].downcase)
    end

    if matching_flights.empty?
      redirect_to search_flights_path(permitted_params), alert: "We are not serving this source and destination." and return
    end

    class_type = permitted_params[:class_type].present? ? permitted_params[:class_type].downcase : 'economy'
    available_flights = matching_flights.select do |flight|
      available_key = "#{class_type.gsub(' ', '_')}_available_seats".to_sym
      flight[available_key].to_i >= passengers
    end

    if available_flights.empty?
      redirect_to search_flights_path(permitted_params), alert: "There are no flights operated from this source to destination with available seats." and return
    end

    if permitted_params[:departure_date].present?
      available_flights = available_flights.select do |flight|
        flight[:departure_date] == permitted_params[:departure_date]
      end

      if available_flights.empty?
        redirect_to search_flights_path(permitted_params), alert: "There are no flights available on the selected date." and return
      end
    end

    @search_results = available_flights.map do |flight|
      price_key = case class_type
      when 'economy' then :economy_base_price
      when 'first class' then :first_class_base_price
      when 'second class' then :second_class_base_price
      end
      available_key = "#{class_type.gsub(' ', '_')}_available_seats".to_sym
      total_seats_key = "#{class_type.gsub(' ', '_')}_total_seats".to_sym

      base_price = flight[price_key].to_f
      available_seats = flight[available_key].to_i
      total_seats = flight[total_seats_key].to_i
      date = flight[:departure_date]

      total_fare = calculate_total_fare(total_seats, available_seats, base_price, passengers, date)

      flight.merge(
        total_cost: total_fare,
        display_price: flight[price_key],
        class_type: class_type,
        seats: available_seats
      )
    end

    render :details
  end
end
