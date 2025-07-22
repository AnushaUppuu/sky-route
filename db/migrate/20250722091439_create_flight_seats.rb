class CreateFlightSeats < ActiveRecord::Migration[8.0]
  def change
    create_table :flight_seats do |t|
      t.references :flight_schedule, null: false, foreign_key: true
      t.references :flight_class, null: false, foreign_key: true
      t.integer :total_seats
      t.integer :available_seats
      t.decimal :price

      t.timestamps
    end
  end
end
