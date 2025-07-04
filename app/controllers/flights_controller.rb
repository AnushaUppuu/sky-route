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

    # Example Update: Change flight price
    flights[0]["price"] = 9999

    File.write(FILE_PATH, JSON.pretty_generate(flights))
    redirect_to root_path, notice: "Flight data updated!"
  end
end
