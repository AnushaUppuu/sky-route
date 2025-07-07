require 'json'

class FlightsController < ApplicationController
  FILE_PATH = Rails.root.join('data', 'data.txt')

  def index
    file_content = File.read(FILE_PATH)
    @flights = JSON.parse(file_content)
  end

  def update
    file_content = File.read(FILE_PATH)
    flights = JSON.parse(file_content)
    flights[0]["price"] = 9999

    File.write(FILE_PATH, JSON.pretty_generate(flights))
    redirect_to root_path, notice: "Flight data updated successfully!"
  end
  def search
    if params[:origin].present? && params[:query].present?
      file_content = File.read(FILE_PATH)
      flights = JSON.parse(file_content)
      search_results = flights.select do |flight|
        flight["destination"].downcase.include?(params[:query].downcase) &&
        flight["source"].downcase.include?(params[:origin].downcase)
      end

      @search_results = search_results
    end
    render :search
  end
  
end
