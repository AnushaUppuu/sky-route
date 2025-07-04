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
    if params[:query].blank? || params[:origin].blank?
      flash[:alert] = "Please provide both destination and origin."
      redirect_to root_path and return
    end
    file_content = File.read(FILE_PATH)
    flights = JSON.parse(file_content)
    search_results = flights.select { |flight| flight["destination"].downcase.include?(params[:query].downcase) && flight["origin"].downcase.include?(params[:origin].downcase) }
    render json: search_results 
  end
end
