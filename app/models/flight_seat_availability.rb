class FlightSeatAvailability < ApplicationRecord
  belongs_to :flight_seat

  validates :scheduled_date, presence: true
  validates :available_seats, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :scheduled_date, uniqueness: { scope: :flight_seat_id }
end
