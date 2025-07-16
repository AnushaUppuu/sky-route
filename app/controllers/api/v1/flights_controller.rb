require "csv"

module Api
  module V1
    class FlightsController < ApplicationController
      include FlightsHelper
      FILE_PATH = Rails.root.join("data", "data.txt")

      def index
        flights = ::FlightDataLoader.load_flights
        render json: { data: flights, message: "Flights fetched successfully" }, status: :ok
      end

      def search
        cities = ::FlightDataLoader.load_unique_cities
        render json: { cities: cities, message: "Available cities fetched successfully" }, status: :ok
      end

      def update_seat_count
        flight_number = params[:flight_number]
        class_type = params[:class_type]
        passengers = params[:passengers].to_i

        if flight_number.blank? || class_type.blank? || passengers <= 0
          return render json: { error: "Invalid booking details" }, status: :bad_request
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
              return render json: { error: "Not enough seats available" }, status: :unprocessable_entity
            end
          end
        end

         if updated
          File.open(FILE_PATH, "w") { |f| f.write(data.to_csv) }
            Rails.cache.delete("flights_data")
            Rails.cache.delete("cities_data")
          render json: { message: "Booking successful" }, status: :ok
        else
          render json: { error: "Flight not found for updating seats" }, status: :not_found
        end
      end

      def details
        permitted_params = params.permit(:source, :destination, :departure_date, :passengers, :class_type)

        if permitted_params[:source] == permitted_params[:destination]
          return render json: { error: "Source and destination cannot be the same" }, status: :bad_request
        end

        unless permitted_params[:source].present? && permitted_params[:destination].present?
          return render json: { error: "Source and destination are required" }, status: :bad_request
        end

        flights = ::FlightDataLoader.load_flights
        passengers = permitted_params[:passengers].present? ? permitted_params[:passengers].to_i : 1

        matching_flights = flights.select do |flight|
          flight[:source].casecmp?(permitted_params[:source]) &&
            flight[:destination].casecmp?(permitted_params[:destination])
        end

        if matching_flights.empty?
          return render json: { error: "No flights found for this source and destination" }, status: :not_found
        end

        class_type = permitted_params[:class_type].present? ? permitted_params[:class_type].downcase : "economy"
        available_key = "#{class_type.gsub(' ', '_')}_available_seats".to_sym

        available_flights = matching_flights.select do |flight|
          flight[available_key].to_i >= passengers
        end

        if permitted_params[:departure_date].present?
          available_flights.select! { |flight| flight[:departure_date] == permitted_params[:departure_date] }
        end

        if available_flights.empty?
          return render json: { error: "No flights available with the given criteria" }, status: :not_found
        end

        results = available_flights.map do |flight|
          price_key = case class_type
          when "economy" then :economy_base_price
          when "first class" then :first_class_base_price
          when "second class" then :second_class_base_price
          end

          total_seats_key = "#{class_type.gsub(' ', '_')}_total_seats".to_sym
          base_price = flight[price_key].to_f
          available_seats = flight[available_key].to_i
          total_seats = flight[total_seats_key].to_i
          date = flight[:departure_date]

          total_fare = calculate_total_fare(total_seats, available_seats, base_price, passengers, date)

          flight.merge(
            total_cost: total_fare,
            display_price: base_price,
            class_type: class_type,
            available_seats: available_seats
          )
          {
            airlines: flight[:airlines],
            flight_number: flight[:flight_number],
            source: flight[:source],
            destination: flight[:destination],
            departure_date: flight[:departure_date],
            departure_time: flight[:departure_time],
            arrival_date: flight[:arrival_date],
            arrival_time: flight[:arrival_time],
            class_type: class_type,
            available_seats: available_seats,
            price: base_price,
            total_cost: total_fare,
            passengers: passengers
          }
        end

        render json: { data: results, message: "Flights matching your criteria" }, status: :ok
      end
    end
  end
end
