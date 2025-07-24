class FlightWeekday < ApplicationRecord
  belongs_to :flight

  validates :day_of_week, presence: true, inclusion: { in: Date::DAYNAMES + Date::ABBR_DAYNAMES }
  validates :day_of_week, uniqueness: { scope: :flight_id }
end
