class FlightSchedule < ApplicationRecord
  belongs_to :flight
  has_many :flight_seats, dependent: :destroy

  validates :departure_time, :arrival_time, :status, presence: true
  validates :flight_id, uniqueness: { scope: [ :departure_time, :arrival_time ] }
end
