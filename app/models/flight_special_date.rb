class FlightSpecialDate < ApplicationRecord
  belongs_to :flight

  validates :special_date, presence: true
  validates :special_date, uniqueness: { scope: :flight_id }
end
