# app/models/city.rb
class City < ApplicationRecord
  has_many :departing_flights, class_name: "Flight", foreign_key: "source_city_id"
  has_many :arriving_flights, class_name: "Flight", foreign_key: "destination_city_id"
end
