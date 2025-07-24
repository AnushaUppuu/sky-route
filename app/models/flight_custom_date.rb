class FlightCustomDate < ApplicationRecord
  belongs_to :flight

  validates :custom_date, presence: true
  validates :custom_date, uniqueness: { scope: :flight_id }
end
