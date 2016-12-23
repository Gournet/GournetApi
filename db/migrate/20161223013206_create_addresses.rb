class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.string :address
      t.decimal :lat
      t.decimal :lng
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
