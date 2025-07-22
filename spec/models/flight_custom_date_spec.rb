require 'rails_helper'

RSpec.describe FlightCustomDate, type: :model do
  it "creates a flight custom date for a flight" do
    airline = Airline.create!(name: "IndiGo", code: "6E")
    source_airport = Airport.create!(name: "Kempegowda International Airport", code: "BLR", city: "Bangalore", country: "India")
    destination_airport = Airport.create!(name: "Chhatrapati Shivaji Maharaj International Airport", code: "BOM", city: "Mumbai", country: "India")
    recurrence = Recurrence.create!(recurrence_type: "custom")

    flight = Flight.create!(
      airline: airline,
      flight_number: "6E123",
      source_airport: source_airport,
      destination_airport: destination_airport,
      recurrence: recurrence
    )

    custom_date = FlightCustomDate.new(flight: flight, custom_date: Date.tomorrow)

    expect(custom_date.save).to be true
  end
end
