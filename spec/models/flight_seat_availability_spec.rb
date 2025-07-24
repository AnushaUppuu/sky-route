require 'rails_helper'

RSpec.describe FlightSeatAvailability, type: :model do
  describe "associations" do
    it "belongs to flight_seat" do
      flight = Flight.create!(
        airline: Airline.create!(name: "IndiGo", code: "6E"),
        source_airport: Airport.create!(name: "BOM Airport", code: "BOM"),
        destination_airport: Airport.create!(name: "BLR Airport", code: "BLR"),
        recurrence: Recurrence.create!(recurrence_type: "Daily"),
        flight_number: "6E101"
      )

      schedule = FlightSchedule.create!(
        flight: flight,
        departure_time: "10:00",
        arrival_time: "12:00",
        status: "Scheduled"
      )

      flight_class = FlightClass.create!(name: "Economy")

      flight_seat = FlightSeat.create!(
        flight_schedule: schedule,
        flight_class: flight_class,
        total_seats: 100,
        price: 5000.00
      )

      availability = FlightSeatAvailability.create!(
        flight_seat: flight_seat,
        scheduled_date: Date.today,
        available_seats: 50
      )

      expect(availability.flight_seat).to eq(flight_seat)
    end
  end

  describe "validations" do
    before(:each) do
      @flight = Flight.create!(
        airline: Airline.create!(name: "IndiGo", code: "6E"),
        source_airport: Airport.create!(name: "BOM Airport", code: "BOM"),
        destination_airport: Airport.create!(name: "BLR Airport", code: "BLR"),
        recurrence: Recurrence.create!(recurrence_type: "Daily"),
        flight_number: "6E101"
      )

      @schedule = FlightSchedule.create!(
        flight: @flight,
        departure_time: "10:00",
        arrival_time: "12:00",
        status: "Scheduled"
      )

      @flight_class = FlightClass.create!(name: "Economy")

      @flight_seat = FlightSeat.create!(
        flight_schedule: @schedule,
        flight_class: @flight_class,
        total_seats: 100,
        price: 5000.00
      )
    end

    it "is valid with valid attributes" do
      availability = FlightSeatAvailability.new(
        flight_seat: @flight_seat,
        scheduled_date: Date.today,
        available_seats: 50
      )
      expect(availability).to be_valid
    end

    it "is invalid without flight_seat" do
      availability = FlightSeatAvailability.new(
        scheduled_date: Date.today,
        available_seats: 50
      )
      expect(availability).to_not be_valid
    end

    it "is invalid without scheduled_date" do
      availability = FlightSeatAvailability.new(
        flight_seat: @flight_seat,
        available_seats: 50
      )
      expect(availability).to_not be_valid
    end

    it "is invalid without available_seats" do
      availability = FlightSeatAvailability.new(
        flight_seat: @flight_seat,
        scheduled_date: Date.today
      )
      expect(availability).to_not be_valid
    end

    it "is invalid with negative available_seats" do
      availability = FlightSeatAvailability.new(
        flight_seat: @flight_seat,
        scheduled_date: Date.today,
        available_seats: -5
      )
      expect(availability).to_not be_valid
    end

    it "enforces uniqueness of scheduled_date scoped to flight_seat_id" do
      FlightSeatAvailability.create!(
        flight_seat: @flight_seat,
        scheduled_date: Date.today,
        available_seats: 50
      )

      duplicate = FlightSeatAvailability.new(
        flight_seat: @flight_seat,
        scheduled_date: Date.today,
        available_seats: 30
      )

      expect(duplicate).to_not be_valid
    end
  end
end
