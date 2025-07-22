class Flight < ApplicationRecord
  belongs_to :airline
  belongs_to :source_airport, class_name: "Airport"
  belongs_to :destination_airport, class_name: "Airport"
  belongs_to :recurrence
end
