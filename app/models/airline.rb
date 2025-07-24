class Airline < ApplicationRecord
  has_many :flights, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
