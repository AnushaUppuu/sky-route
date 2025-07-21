module Api
  module V1
    class FlightsController < ApplicationController
      include FlightsHelper
      def update_seat_count
        flight_number = params[:flight_number]
        class_type = params[:class_type]&.downcase
        passengers = params[:passengers].to_i

        if flight_number.blank? || class_type.blank? || passengers <= 0
          return render json: { error: "Invalid booking details" }, status: :bad_request
        end

        seat_columns = {
          "economy" => :economy_available_seats,
          "first class" => :first_class_available_seats,
          "second class" => :second_class_available_seats
        }

        available_seats_column = seat_columns[class_type]

        unless available_seats_column
          return render json: { error: "Invalid class type" }, status: :bad_request
        end

        flight = Flight.find_by(flight_number: flight_number)

        unless flight
          return render json: { error: "Flight not found for updating seats" }, status: :not_found
        end

        current_seats = flight[available_seats_column].to_i

        if current_seats >= passengers
          flight.update!(available_seats_column => current_seats - passengers)
          render json: { message: "Booking successful" }, status: :ok
        else
          render json: { error: "Not enough seats available" }, status: :unprocessable_entity
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

        passengers = permitted_params[:passengers].present? ? permitted_params[:passengers].to_i : 1
        class_type = permitted_params[:class_type]&.downcase || "economy"
        currency = params[:currency_type]&.upcase || "INR"

        source_city = City.find_by(name: permitted_params[:source])
        destination_city = City.find_by(name: permitted_params[:destination])

        unless source_city && destination_city
          return render json: { error: "Invalid source or destination city" }, status: :bad_request
        end

        flights = Flight.where(source_city_id: source_city.id, destination_city_id: destination_city.id)
        flights = flights.where(departure_date: permitted_params[:departure_date]) if permitted_params[:departure_date].present?

        class_type_columns = {
          "economy" => {
            price: :economy_base_price,
            total_seats: :economy_total_seats,
            available_seats: :economy_available_seats
          },
          "first class" => {
            price: :first_class_base_price,
            total_seats: :first_class_total_seats,
            available_seats: :first_class_available_seats
          },
          "second class" => {
            price: :second_class_base_price,
            total_seats: :second_class_total_seats,
            available_seats: :second_class_available_seats
          }
        }

        columns = class_type_columns[class_type] || class_type_columns["economy"]

        price_column = columns[:price]
        total_seats_column = columns[:total_seats]
        available_seats_column = columns[:available_seats]

        available_flights = flights.select do |flight|
          flight[available_seats_column].to_i >= passengers
        end

        if available_flights.empty?
          return render json: { error: "No flights available on the selected date" }, status: :not_found
        end

        results = available_flights.map do |flight|
          base_price = flight[price_column].to_f
          available_seats = flight[available_seats_column].to_i
          total_seats = flight[total_seats_column].to_i

          total_fare = calculate_total_fare(
            total_seats,
            available_seats,
            base_price,
            passengers,
            permitted_params[:departure_date]
          )
          converted_price = convert_currency(base_price, currency)
          converted_total = convert_currency(total_fare, currency)
          {
            airlines: flight.airlines,
            flight_number: flight.flight_number,
            source: permitted_params[:source],
            destination: permitted_params[:destination],
            departure_date: flight.departure_date,
            departure_time: flight.departure_time.strftime("%H:%M"),
            arrival_date: flight.arrival_date,
            arrival_time: flight.arrival_time.strftime("%H:%M"),
            class_type: class_type,
            available_seats: available_seats,
            price_per_ticket: converted_price[:amount],
            total_cost: converted_total[:amount],
            passengers: passengers,
            currency: currency_symbol(currency)
          }
        end

        render json: { data: results, message: "Flights fetched successfully" }, status: :ok
      end
    end
  end
end
