class CreateAirports < ActiveRecord::Migration[8.0]
  def change
    create_table :airports do |t|
      t.string :name
      t.string :code
      t.string :city
      t.string :country

      t.timestamps
    end
  end
end
