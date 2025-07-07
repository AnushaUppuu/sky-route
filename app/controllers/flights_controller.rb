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
    if params[:source].present? && params[:destination].present? && params[:departure_date].present?
      flights = load_flights_from_txt
      search_results = flights.select do |flight|
        flight[:destination].to_s.downcase.include?(params[:destination].downcase) &&
        flight[:source].to_s.downcase.include?(params[:source].downcase) && 
          flight[:departure_date].to_s.downcase.include?(params[:departure_date].downcase)
      end
      @search_results = search_results.presence || []
    else 
      @search_results = []
    end
    render :details
  end

  
end
