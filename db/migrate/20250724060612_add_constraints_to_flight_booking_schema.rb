class AddConstraintsToFlightBookingSchema < ActiveRecord::Migration[8.0]
  def change
    # Airports
    change_column_null :airports, :name, false
    change_column_null :airports, :code, false
    add_index :airports, :code, unique: true

    # Airlines
    change_column_null :airlines, :name, false
    change_column_null :airlines, :code, false
    add_index :airlines, :code, unique: true

    # FlightClasses
    change_column_null :flight_classes, :name, false
    add_index :flight_classes, :name, unique: true

    # Recurrences
    change_column_null :recurrences, :recurrence_type, false
    add_index :recurrences, :recurrence_type, unique: true

    # Flights
    change_column_null :flights, :flight_number, false
    add_index :flights, :flight_number, unique: true

    # FlightWeekdays
    change_column_null :flight_weekdays, :day_of_week, false
    add_index :flight_weekdays, [ :flight_id, :day_of_week ], unique: true, name: 'index_flight_weekdays_on_flight_and_day'

    # FlightSpecialDates
    change_column_null :flight_special_dates, :special_date, false
    add_index :flight_special_dates, [ :flight_id, :special_date ], unique: true, name: 'index_flight_special_dates_on_flight_and_date'

    # FlightCustomDates
    change_column_null :flight_custom_dates, :custom_date, false
    add_index :flight_custom_dates, [ :flight_id, :custom_date ], unique: true, name: 'index_flight_custom_dates_on_flight_and_date'

    # FlightSchedules
    change_column_null :flight_schedules, :departure_time, false
    change_column_null :flight_schedules, :arrival_time, false
    change_column_null :flight_schedules, :status, false
    add_index :flight_schedules, [ :flight_id, :departure_time, :arrival_time ], unique: true, name: 'index_flight_schedules_on_flight_and_times'

    # FlightSeats
    change_column_null :flight_seats, :total_seats, false
    change_column_null :flight_seats, :price, false
    add_index :flight_seats, [ :flight_schedule_id, :flight_class_id ], unique: true, name: 'index_flight_seats_on_schedule_and_class'
  end
end
