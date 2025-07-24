class Flight < ApplicationRecord
  belongs_to :airline
  belongs_to :source_airport, class_name: "Airport"
  belongs_to :destination_airport, class_name: "Airport"
  belongs_to :recurrence

  has_many :flight_schedules, dependent: :destroy
  has_many :flight_weekdays, dependent: :destroy
  has_many :flight_special_dates, dependent: :destroy
  has_many :flight_custom_dates, dependent: :destroy

  validates :flight_number, presence: true, uniqueness: true
end
