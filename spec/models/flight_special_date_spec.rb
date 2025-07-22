require 'rails_helper'

RSpec.describe FlightSpecialDate, type: :model do
  it "creates a flight special date for a flight" do
    airline = Airline.create!(name: "IndiGo", code: "6E")
    source_airport = Airport.create!(name: "Kempegowda International Airport", code: "BLR", city: "Bangalore", country: "India")
    destination_airport = Airport.create!(name: "Chhatrapati Shivaji Maharaj International Airport", code: "BOM", city: "Mumbai", country: "India")
    recurrence = Recurrence.create!(recurrence_type: "special")

    flight = Flight.create!(
      airline: airline,
      flight_number: "6E456",
      source_airport: source_airport,
      destination_airport: destination_airport,
      recurrence: recurrence
    )

    special_date = FlightSpecialDate.new(flight: flight, special_date: Date.today + 7)

    expect(special_date.save).to be true
  end
end
