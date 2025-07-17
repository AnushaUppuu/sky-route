class AddAvailableSeatsToFlights < ActiveRecord::Migration[8.0]
  def change
    add_column :flights, :economy_available_seats, :integer
    add_column :flights, :first_class_available_seats, :integer
    add_column :flights, :second_class_available_seats, :integer
  end
end
