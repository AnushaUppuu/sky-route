module Api
  module V1
    class FlightsController < ApplicationController
      include FlightsHelper

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
            price_per_ticket: base_price,
            total_cost: total_fare,
            passengers: passengers
          }
        end

        render json: { data: results, message: "Flights fetched successfully" }, status: :ok
      end
    end
  end
end
