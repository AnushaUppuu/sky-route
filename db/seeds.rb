require 'csv'

puts "🌱 Starting clean seeding..."

csv_folder = Rails.root.join("db/csv")

[
  FlightSeatAvailability,
  FlightSeat,
  FlightSchedule,
  FlightWeekday,
  FlightSpecialDate,
  FlightCustomDate,
  Flight,
  FlightClass,
  Recurrence,
  Airline,
  Airport
].each do |model|
  model.destroy_all
  puts "🗑️  Cleared #{model} records."
end

model_files = {
  Airline => "airlines.csv",
  Airport => "airports.csv",
  Recurrence => "recurrences.csv",
  FlightClass => "flightclasses.csv",
  Flight => "flights.csv",
  FlightSchedule => "flight_schedules.csv",
  FlightSeat => "flight_seats.csv",
  FlightSeatAvailability => "flight_seat_availability.csv",
  FlightWeekday => "flight_weekdays.csv",
  FlightSpecialDate => "flight_special_dates.csv",
  FlightCustomDate => "flight_custom_dates.csv"
}

model_files.each do |model, file_name|
  file_path = csv_folder.join(file_name)
  unless File.exist?(file_path)
    puts "⚠️  File #{file_name} not found, skipping..."
    next
  end

  puts "🗂️  Seeding #{model} from #{file_name}..."

  CSV.foreach(file_path, headers: true) do |row|
    begin
      model.create!(row.to_h)
    rescue ActiveRecord::RecordInvalid => e
      puts "❌ Failed to create #{model}: #{e.message}"
    end
  end
end

puts "✅ Seeding completed successfully."
