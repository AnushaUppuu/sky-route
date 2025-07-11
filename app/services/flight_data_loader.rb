require "csv"

class FlightDataLoader
  FILE_PATH = if Rails.env.test?
                Rails.root.join("data", "test.txt")
  else
                Rails.root.join("data", "data.txt")
  end

  def self.load_flights
    Rails.cache.fetch("flights_data", expires_in: 12.hours) do
      flights = []
      CSV.foreach(FILE_PATH, headers: true) do |row|
        flights << row.to_h.symbolize_keys
      end
      flights
    end
  end

  def self.load_unique_cities
    Rails.cache.fetch("cities_data", expires_in: 12.hours) do
      flights = load_flights
      sources = flights.map { |f| f[:source] }
      destinations = flights.map { |f| f[:destination] }
      (sources + destinations).uniq.compact.sort
    end
  end
end
