require 'csv'

class FlightsController < ApplicationController
  FILE_PATH = Rails.root.join('data', 'data.txt')

  def index
  end

   def search
    render :search
  end

  def load_flights_from_txt
    flights = []
    CSV.foreach(FILE_PATH, headers: true) do |row|
      flights << row.to_h.symbolize_keys
    end

    flights
  end

  def details
    if params[:source].present? && params[:destination].present? && params[:class_type].present?
      flights = load_flights_from_txt
      search_results = flights.select do |flight|
        flight[:source].downcase.include?(params[:source].downcase) &&
        flight[:destination].downcase.include?(params[:destination].downcase)
      end

      class_type = params[:class_type].downcase
      search_results = search_results.select do |flight|
          available_key = "#{class_type.gsub(' ', '_')}_available_seats".to_sym
          flight[available_key].to_i > 0
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
          flight.merge(display_price: flight[price_key])
        end
    else
      @search_results = []
    end

    render :details
  end
end
