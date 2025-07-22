class CreateFlights < ActiveRecord::Migration[8.0]
  def change
    create_table :flights do |t|
      t.references :airline, null: false, foreign_key: true
      t.string :flight_number
      t.references :source_airport, null: false, foreign_key: { to_table: :airports }
      t.references :destination_airport, null: false, foreign_key: { to_table: :airports }
      t.references :recurrence, null: false, foreign_key: true

      t.timestamps
    end
  end
end
