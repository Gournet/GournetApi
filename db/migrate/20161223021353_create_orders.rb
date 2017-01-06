class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.integer :count, :null => false, :default => 1
      t.decimal :price
      t.text :comment
      t.references :address, foreign_key: true
      t.references :user, foreign_key: true
      t.references :dish, foreign_key: true
      t.references :chef, foreign_key: true

      t.timestamps
    end
  end
end
