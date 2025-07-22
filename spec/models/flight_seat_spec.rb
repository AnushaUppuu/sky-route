require 'rails_helper'

RSpec.describe FlightSeat, type: :model do
  it "creates a flight seat for a flight schedule and class" do
    # Create dependencies
    airline = Airline.create!(name: "Air India", code: "AI")
    source_airport = Airport.create!(name: "Delhi Airport", code: "DEL", city: "Delhi", country: "India")
    destination_airport = Airport.create!(name: "Chennai Airport", code: "MAA", city: "Chennai", country: "India")
    recurrence = Recurrence.create!(recurrence_type: "daily")

    flight = Flight.create!(
      airline: airline,
      flight_number: "AI302",
      source_airport: source_airport,
      destination_airport: destination_airport,
      recurrence: recurrence
    )

    flight_schedule = FlightSchedule.create!(
      flight: flight,
      departure_time: Time.zone.now + 1.day,
      arrival_time: Time.zone.now + 1.day + 3.hours,
      status: "on_time"
    )

    flight_class = FlightClass.create!(name: "Economy")

    seat = FlightSeat.new(
      flight_schedule: flight_schedule,
      flight_class: flight_class,
      total_seats: 150,
      available_seats: 150,
      price: 3500.0
    )

    expect(seat.save).to be true
  end
end
