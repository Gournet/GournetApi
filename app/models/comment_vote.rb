class CommentVote < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :comment

  def self.add_vote(user_id,comment_id,vote = 1)
    new_rating = find_or_initialize_by(user_id: user_id,comment_id: comment_id)
    new_rating.is_possitive = vote
    new_rating.save
  end

  validates :is_possitive, presence: true
  validates_inclusion_of :is_possitive, :in => -1..1

end
