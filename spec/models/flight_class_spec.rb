require 'rails_helper'

RSpec.describe FlightClass, type: :model do
  it "creates a flight class successfully" do
    flight_class = FlightClass.new(name: "Economy")

    expect(flight_class.save).to be true
  end
end
