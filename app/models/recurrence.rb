class Recurrence < ApplicationRecord
  has_many :flights, dependent: :restrict_with_exception

  validates :recurrence_type, presence: true, uniqueness: true
end
