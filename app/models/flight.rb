class Flight < ApplicationRecord
  belongs_to :source_city, class_name: "City"
  belongs_to :destination_city, class_name: "City"
end
