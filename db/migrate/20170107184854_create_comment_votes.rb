class CreateCommentVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :comment_votes do |t|
      t.integer :is_possitive, :default => 1
      t.references :user, foreign_key: true
      t.references :comment, foreign_key: true

      t.timestamps
    end
    add_index :comment_votes, [:user_id,:comment_id], :unique => true
  end
end
