class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.text :description
      t.integer :order, :null => false
      t.string :image
      t.references :dish, foreign_key: true

      t.timestamps
    end
    add_index :images, [:dish_id,:order], :unique => true 
  end
end
