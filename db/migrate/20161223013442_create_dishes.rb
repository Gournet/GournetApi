class CreateDishes < ActiveRecord::Migration[5.0]
  def change
    create_table :dishes do |t|
      t.string :name, :null => false
      t.text :description
      t.decimal :price
      t.decimal :cooking_time
      t.decimal :calories
      t.references :chef, foreign_key: true

      t.timestamps
    end
  end
end
