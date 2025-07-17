class CreateFlights < ActiveRecord::Migration[8.0]
  def change
    create_table :flights do |t|
      t.string :airlines
      t.string :flight_number
      t.bigint :source_city_id, null: false
      t.bigint :destination_city_id, null: false
      t.decimal :economy_base_price
      t.decimal :first_class_base_price
      t.decimal :second_class_base_price
      t.integer :economy_total_seats
      t.integer :first_class_total_seats
      t.integer :second_class_total_seats
      t.date :departure_date
      t.time :departure_time
      t.date :arrival_date
      t.time :arrival_time
      t.timestamps
    end
      add_foreign_key :flights, :cities, column: :source_city_id
      add_foreign_key :flights, :cities, column: :destination_city_id
  end
end
