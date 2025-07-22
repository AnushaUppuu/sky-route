class CreateFlightCustomDates < ActiveRecord::Migration[8.0]
  def change
    create_table :flight_custom_dates do |t|
      t.references :flight, null: false, foreign_key: true
      t.date :custom_date

      t.timestamps
    end
  end
end
