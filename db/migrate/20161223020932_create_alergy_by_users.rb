class CreateAlergyByUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :alergy_by_users do |t|
      t.references :user, foreign_key: true
      t.references :alergy, foreign_key: true

      t.timestamps
    end
  end
end
