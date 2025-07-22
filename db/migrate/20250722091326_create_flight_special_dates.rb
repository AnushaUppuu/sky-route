class CreateFlightSpecialDates < ActiveRecord::Migration[8.0]
  def change
    create_table :flight_special_dates do |t|
      t.references :flight, null: false, foreign_key: true
      t.date :special_date

      t.timestamps
    end
  end
end
