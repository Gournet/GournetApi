class RenameTypeToChef < ActiveRecord::Migration[5.0]
  def up
    rename_column :chefs, :type, :type_chef
  end
end
