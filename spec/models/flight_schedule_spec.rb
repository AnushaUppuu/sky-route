require 'rails_helper'

RSpec.describe FlightSchedule, type: :model do
  it "creates a flight schedule for a flight" do
    airline = Airline.create!(name: "IndiGo", code: "6E")
    source_airport = Airport.create!(name: "Kempegowda International Airport", code: "BLR", city: "Bangalore", country: "India")
    destination_airport = Airport.create!(name: "Chhatrapati Shivaji Maharaj International Airport", code: "BOM", city: "Mumbai", country: "India")
    recurrence = Recurrence.create!(recurrence_type: "daily")

    flight = Flight.create!(
      airline: airline,
      flight_number: "6E123",
      source_airport: source_airport,
      destination_airport: destination_airport,
      recurrence: recurrence
    )

    schedule = FlightSchedule.new(
      flight: flight,
      departure_time: Time.zone.now + 1.day,
      arrival_time: Time.zone.now + 1.day + 2.hours,
      status: "on_time"
    )

    expect(schedule.save).to be true
  end
end
