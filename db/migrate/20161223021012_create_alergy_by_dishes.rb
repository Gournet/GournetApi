class CreateAlergyByDishes < ActiveRecord::Migration[5.0]
  def change
    create_table :alergy_by_dishes do |t|
      t.references :alergy, foreign_key: true
      t.references :dish, foreign_key: true

      t.timestamps
    end
  end
end
