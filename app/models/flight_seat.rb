class FlightSeat < ApplicationRecord
  belongs_to :flight_schedule
  belongs_to :flight_class
  has_many :flight_seat_availabilities, dependent: :destroy

  validates :total_seats, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :flight_schedule_id, uniqueness: { scope: :flight_class_id }
end
