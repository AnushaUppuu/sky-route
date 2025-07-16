require 'csv'

filepath = Rails.root.join('data', 'data.txt')
# Collect all unique city IDs from flight data
city_ids = Set.new

CSV.foreach(filepath, headers: true) do |row|
  city_ids << row['source_city_id'].to_i
  city_ids << row['destination_city_id'].to_i
end

# Create cities with placeholder names if names aren't available
city_ids.each do |id|
  City.find_or_create_by!(id: id) do |city|
    city.name = "City#{id}" # You can change this placeholder logic
  end
end
CSV.foreach(filepath, headers: true) do |row|
  Flight.create!(
    airlines: row['airlines'],
    flight_number: row['flight_number'],
    source_city_id: row['source_city_id'].to_i,
    destination_city_id: row['destination_city_id'].to_i,
    economy_base_price: row['economy_base_price'].to_f,
    first_class_base_price: row['first_class_base_price'].to_f,
    second_class_base_price: row['second_class_base_price'].to_f,
    economy_total_seats: row['economy_total_seats'].to_i,
    first_class_total_seats: row['first_class_total_seats'].to_i,
    second_class_total_seats: row['second_class_total_seats'].to_i,
    departure_date: row['departure_date'],
    departure_time: row['departure_time'],
    arrival_date: row['arrival_date'],
    arrival_time: row['arrival_time']
  )
end

puts "Imported flights from data/data.txt"
