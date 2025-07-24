class Airport < ApplicationRecord
  has_many :departing_flights, class_name: "Flight", foreign_key: :source_airport_id, dependent: :restrict_with_exception
  has_many :arriving_flights, class_name: "Flight", foreign_key: :destination_airport_id, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
