class CreateRecurrences < ActiveRecord::Migration[8.0]
  def change
    create_table :recurrences do |t|
      t.string :recurrence_type

      t.timestamps
    end
  end
end
