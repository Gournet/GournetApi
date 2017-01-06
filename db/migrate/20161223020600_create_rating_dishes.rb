class CreateRatingDishes < ActiveRecord::Migration[5.0]
  def change
    create_table :rating_dishes do |t|
      t.references :user, foreign_key: true
      t.references :dish, foreign_key: true
      t.integer :rating

      t.timestamps
    end
    add_index :rating_dishes, [:user_id,:dish_id], :unique => true
  end
end
