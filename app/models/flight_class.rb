class FlightClass < ApplicationRecord
  has_many :flight_seats, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
end
