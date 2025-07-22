require 'rails_helper'

RSpec.describe Flight, type: :model do
  let(:airline) { Airline.create!(name: "IndiGo", code: "6E") }
  let(:source_airport) { Airport.create!(name: "Bangalore Airport", code: "BLR", city: "Bangalore", country: "India") }
  let(:destination_airport) { Airport.create!(name: "Chennai Airport", code: "MAA", city: "Chennai", country: "India") }
  let(:recurrence) { Recurrence.create!(recurrence_type: "daily") }

  it "creates a flight successfully" do
    flight = Flight.new(
      airline: airline,
      source_airport: source_airport,
      destination_airport: destination_airport,
      recurrence: recurrence,
      flight_number: "6E123"
    )

    expect(flight.save).to be true
  end
end
