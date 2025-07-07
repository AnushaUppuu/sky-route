require 'json'

class FlightsController < ApplicationController
  FILE_PATH = Rails.root.join('data', 'data.txt')

  def index
  end

  def update
    file_content = File.read(FILE_PATH)
    flights = JSON.parse(file_content)
    flights[0]["price"] = 9999

    File.write(FILE_PATH, JSON.pretty_generate(flights))
    redirect_to root_path, notice: "Flight data updated successfully!"
  end
  def search
    render :search
  end
  def details
    if params[:source].present? && params[:destination].present?
      file_content = File.read(FILE_PATH)
      flights = JSON.parse(file_content)
      search_results = flights.select do |flight|
        flight["destination"].downcase.include?(params[:destination].downcase) &&
        flight["source"].downcase.include?(params[:source].downcase)
      end

      @search_results = search_results
    end
    render :details
  end
end
