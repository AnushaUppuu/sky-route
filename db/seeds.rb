require 'csv'
require 'set'

filepath = Rails.root.join('data', 'data.txt')

# Store unique city names
city_names = Set.new
flights_data = []

# Step 1: Extract city names and store flight rows
CSV.foreach(filepath, headers: true) do |row|
  city_names << row['source']
  city_names << row['destination']
  flights_data << row
end

# Step 2: Seed unique cities into the cities table
city_name_to_id = {}

city_names.to_a.compact.uniq.sort.each do |city_name|
  city = City.find_or_create_by!(name: city_name)
  city_name_to_id[city_name] = city.id
end

puts "✅ Seeded #{city_name_to_id.size} unique cities."

# Optional: Reload city name to ID mapping from DB for safety
# city_name_to_id = City.pluck(:name, :id).to_h

# Step 3: Seed flights using city name → city ID mapping
flights_data.each do |row|
  source_name = row['source']
  destination_name = row['destination']

  source_id = city_name_to_id[source_name]
  destination_id = city_name_to_id[destination_name]

  if source_id.nil? || destination_id.nil?
    puts "⚠️ Skipping flight #{row['flight_number']} due to missing city mapping."
    next
  end

  Flight.create!(
    airlines: row['airlines'],
    flight_number: row['flight_number'],
    source_city_id: source_id,
    destination_city_id: destination_id,
    economy_base_price: row['economy_base_price'].to_f,
    first_class_base_price: row['first_class_base_price'].to_f,
    second_class_base_price: row['second_class_base_price'].to_f,
    economy_total_seats: row['economy_total_seats'].to_i,
    first_class_total_seats: row['first_class_total_seats'].to_i,
    second_class_total_seats: row['second_class_total_seats'].to_i,
    economy_available_seats: row['economy_available_seats'].to_i,
    first_class_available_seats: row['first_class_available_seats'].to_i,
    second_class_available_seats: row['second_class_available_seats'].to_i,
    departure_date: row['departure_date'],
    departure_time: row['departure_time'],
    arrival_date: row['arrival_date'],
    arrival_time: row['arrival_time']
  )
end

puts "✅ Seeded #{flights_data.size} flights from data/data.txt"
