class SimpleCommentSerializer < ActiveModel::Serializer
  attributes :id,:description
  attribute :type
  attribute :likes
  attribute :dislikes
  belongs_to :user_id
  belongs_to :dish_id

  def type
    "comment"
  end

  def likes
    CommentVote.where(comment_id: object.id).where(is_possitive: 1).count
  end

  def dislikes
    CommentVote.where(comment_id: object.id).where(is_possitive: -1).count
  end

end
