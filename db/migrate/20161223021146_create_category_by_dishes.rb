class CreateCategoryByDishes < ActiveRecord::Migration[5.0]
  def change
    create_table :category_by_dishes do |t|
      t.references :category, foreign_key: true
      t.references :dish, foreign_key: true

      t.timestamps
    end
  end
end
