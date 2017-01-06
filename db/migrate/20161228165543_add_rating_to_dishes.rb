class AddRatingToDishes < ActiveRecord::Migration[5.0]
  def change
    add_column :dishes, :rating, :decimal, default: 0
  end
end
