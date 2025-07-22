require 'csv'

def seed_from_csv(model, path, map_headers = {})
  puts "Seeding #{model} from #{path}..."
  CSV.foreach(path, headers: true) do |row|
    attrs = row.to_h.transform_keys { |key| map_headers[key] || key }
    model.create!(attrs)
  end
end

base_path = Rails.root.join('db', 'csv')
FlightSeat.delete_all
FlightSchedule.delete_all
FlightCustomDate.delete_all
FlightSpecialDate.delete_all
FlightWeekday.delete_all
Flight.delete_all
Recurrence.delete_all
FlightClass.delete_all
Airline.delete_all
Airport.delete_all
seed_from_csv(Airport, base_path.join('airports.csv'))
seed_from_csv(Airline, base_path.join('airlines.csv'))
seed_from_csv(FlightClass, base_path.join('flightclasses.csv'))
seed_from_csv(Recurrence, base_path.join('recurrences.csv'))
seed_from_csv(Flight, base_path.join('flights.csv'))
seed_from_csv(FlightWeekday, base_path.join('flight_weekdays.csv'))
seed_from_csv(FlightSpecialDate, base_path.join('flight_special_dates.csv'))
seed_from_csv(FlightCustomDate, base_path.join('flight_custom_dates.csv'))
seed_from_csv(FlightSchedule, base_path.join('flight_schedules.csv'))
seed_from_csv(FlightSeat, base_path.join('flight_seats.csv'))

puts "Seeding complete!"
