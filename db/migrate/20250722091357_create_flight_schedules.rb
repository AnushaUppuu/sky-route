class CreateFlightSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :flight_schedules do |t|
      t.references :flight, null: false, foreign_key: true
      t.time :departure_time
      t.time :arrival_time
      t.string :status

      t.timestamps
    end
  end
end
