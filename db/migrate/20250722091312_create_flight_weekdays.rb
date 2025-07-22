class CreateFlightWeekdays < ActiveRecord::Migration[8.0]
  def change
    create_table :flight_weekdays do |t|
      t.references :flight, null: false, foreign_key: true
      t.string :day_of_week

      t.timestamps
    end
  end
end
