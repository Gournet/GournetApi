class Comment < ApplicationRecord

  default_scope {order('created_at DESC')}
  scope :possitve_comments, -> {where('is_possitive > 0')}
  scope :order_by_score, -> {reorder('is_possitive DESC, created_at DESC')}

  def self.load_comments(page = 1,per_page = 10)
    includes(:user,:dish)
      .paginate(:page => page, :per_page => per_page)
  end

  def self.comment_by_id(id)
    includes(:user,:dish).find_by_id(id)
  end

  belongs_to :user
  belongs_to :dish

  validates :description, :is_possitive, presence: true
  validates :description, length: { in: 10...250 }
  validates_inclusion_of :is_possitive, :in => -1..1

end
