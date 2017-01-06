class ChangeRatingTypeInRatingDishes < ActiveRecord::Migration[5.0]
  def change
    change_column :rating_dishes, :rating, :decimal
  end
end
