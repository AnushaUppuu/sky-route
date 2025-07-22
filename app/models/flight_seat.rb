class FlightSeat < ApplicationRecord
  belongs_to :flight_schedule
  belongs_to :flight_class
end
