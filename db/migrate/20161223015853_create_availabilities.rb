class CreateAvailabilities < ActiveRecord::Migration[5.0]
  def change
    create_table :availabilities do |t|
      t.date :day, :null => false
      t.integer :count
      t.boolean :available, :null => false, :default => true
      t.time :end_time
      t.boolean :repeat, :null => false, :default => false
      t.references :dish, foreign_key: true

      t.timestamps
    end
  end
end
