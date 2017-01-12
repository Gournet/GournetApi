class CommentSerializer < ActiveModel::Serializer
  attributes :id,:description
  belongs_to :user
  belongs_to :chef
  has_many :c_users
end
