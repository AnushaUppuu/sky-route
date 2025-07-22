require 'rails_helper'

RSpec.describe Flight, type: :model do
  it "creates a valid flight with associated records" do
    airline = Airline.create(name: "Test Airline", code: "TA")
    source = Airport.create(name: "Source Airport", code: "SRC", city: "CityA", country: "CountryA")
    destination = Airport.create(name: "Destination Airport", code: "DST", city: "CityB", country: "CountryB")
    recurrence = Recurrence.create(recurrence_type: "daily")

    flight = Flight.new(
      airline: airline,
      source_airport: source,
      destination_airport: destination,
      recurrence: recurrence,
      flight_number: "TA123"
    )

    expect(flight.save).to be true
  end
end
