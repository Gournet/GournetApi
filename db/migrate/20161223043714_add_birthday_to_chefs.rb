class AddBirthdayToChefs < ActiveRecord::Migration[5.0]
  def change
    add_column :chefs, :birthday, :date
  end
end
