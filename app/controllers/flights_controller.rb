require 'csv'
require 'json'

class FlightsController < ApplicationController
  include FlightsHelper
  FILE_PATH = Rails.root.join('data', 'data.txt')
  SEATS_FILE_PATH=Rails.root.join('data','seats.json')
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
  def seats
    if params[:flight_number].blank?
     redirect_to details_flights_path and return 
    end
    puts params[:flight_number]
    flights = load_flights_from_txt
    required_flight_number = params[:flight_number].to_s
    puts "Required: #{required_flight_number}"
    flight = flights.find { |f| f[:flight_number] == required_flight_number }
    puts flight
    if flight
      puts "Flight found: #{flight}"
    else
      puts "Flight not found."
    end
    

    return render plain: "Flight not found", status: 404 unless flight
  

    seats_data = JSON.parse(File.read(SEATS_FILE_PATH))
    puts seats_data
    # Find seat info for the flight number
    flight_seat_info = seats_data.find { |flight| flight["flight_number"] == required_flight_number }
  
    if flight_seat_info.nil?
      @seats = {}  # Return empty hash if no seats found
    else
      # Structure: { "economy" => { seat_number => status }, ... }
      @seats = flight_seat_info["seats"]
    end
  
    render :seats
  end
  
  def load_unique_cities
    flights = load_flights_from_txt
    sources = flights.map { |f| f[:source] }
    destinations = flights.map { |f| f[:destination] }
    (sources + destinations).uniq.compact.sort
  end

  def details
    if params[:source].present? && params[:destination].present? && params[:source] == params[:destination]
      flash[:alert] = "Source and destination cannot be the same."
      redirect_to search_flights_path and return
    end

    if params[:source].present? && params[:destination].present?
      flights = load_flights_from_txt
      passengers = params[:passengers].present? ? params[:passengers].to_i : 1
      search_results = flights.select do |flight|
        flight[:source].downcase.include?(params[:source].downcase) &&
        flight[:destination].downcase.include?(params[:destination].downcase)
      end

      class_type = params[:class_type].present? ? params[:class_type].downcase : 'economy'
      search_results = search_results.select do |flight|
          available_key = "#{class_type.gsub(' ', '_')}_available_seats".to_sym
          flight[available_key].to_i >= passengers
        end

      if params[:departure_date].present?
        search_results = search_results.select do |flight|
          flight[:departure_date] == params[:departure_date]
        end
      end
      @search_results = search_results.map do |flight|
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
        date=flight[:departure_date] 
        total_fare = calculate_total_fare(total_seats, available_seats, base_price, passengers, date)
          flight.merge(total_cost: total_fare, display_price: flight[price_key])
        end
    else
      flash[:alert] = "Select both the source and destination cities"
      redirect_to search_flights_path and return
    end

    render :details
  end
end
