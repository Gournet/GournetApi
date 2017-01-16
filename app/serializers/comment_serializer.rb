class CommentSerializer < ActiveModel::Serializer
  attributes :id,:description
  attribute :type
  belongs_to :user
  belongs_to :dish
  has_many :c_users, key: :user_likes_or_dislikes

  def type
    "comment"
  end

end
