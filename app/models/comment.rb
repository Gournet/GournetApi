class Comment < ApplicationRecord

  default_scope {order('created_at DESC')}
  scope :possitve_comments, -> {where('is_possitive > 0').reorder('is_possitive DESC')}
  scope :order_by_score, -> {reorder('is_possitive DESC, created_at DESC')}

  belongs_to :user
  belongs_to :dish

  validates :description, :is_possitive, presence: true
  validates :description, length: { in: 10...250 }
  validates_inclusion_of :is_possitive, :in => -1..1

end
