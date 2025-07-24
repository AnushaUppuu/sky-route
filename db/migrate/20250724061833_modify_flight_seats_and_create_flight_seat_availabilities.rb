class ModifyFlightSeatsAndCreateFlightSeatAvailabilities < ActiveRecord::Migration[8.0]
  def change
    # Remove `available_seats` from `flight_seats` since we will track availability per date now
    remove_column :flight_seats, :available_seats, :integer

    # Ensure consistent precision and scale for `price`
    change_column :flight_seats, :price, :decimal, precision: 10, scale: 2

    # Create `flight_seat_availabilities` for per-date seat tracking
    create_table :flight_seat_availabilities do |t|
      t.references :flight_seat, null: false, foreign_key: true
      t.date :scheduled_date, null: false
      t.integer :available_seats, null: false

      t.timestamps
    end

    add_index :flight_seat_availabilities, [:flight_seat_id, :scheduled_date],
              unique: true,
              name: 'index_flight_seat_availabilities_on_seat_and_date'
  end
end
