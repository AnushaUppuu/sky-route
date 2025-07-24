require 'rails_helper'

RSpec.describe FlightSeat, type: :model do
  it "creates a flight seat and its availability for a flight schedule and class" do
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
      departure_time: "10:00",
      arrival_time: "13:00",
      status: "on_time"
    )

    flight_class = FlightClass.create!(name: "Economy")

    seat = FlightSeat.create!(
      flight_schedule: flight_schedule,
      flight_class: flight_class,
      total_seats: 150,
      price: 3500.0
    )

    availability = FlightSeatAvailability.create!(
      flight_seat: seat,
      scheduled_date: Date.today,
      available_seats: 150
    )
    expect(seat.total_seats).to eq(150)
    expect(seat.flight_schedule).to eq(flight_schedule)
    expect(seat.flight_class).to eq(flight_class)
    expect(seat.price).to eq(3500.0)

    expect(availability.available_seats).to eq(150)
    expect(availability.flight_seat).to eq(seat)
    expect(availability.scheduled_date).to eq(Date.today)
  end
end
