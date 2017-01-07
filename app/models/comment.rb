class Comment < ApplicationRecord

  default_scope {order('created_at DESC')}


  def self.load_comments(page = 1,per_page = 10)
    includes(:user,:dish,:c_users,:comment_votes)
      .paginate(:page => page, :per_page => per_page)
  end

  def self.comments_by_dish(dish_id,page = 1, per_page = 10)
    includes(:user,:dish,:c_users,:comment_votes)
      .where(dish_id: dish_id)
      .paginate(:page => page, :per_page => per_page)
  end

  def self.comments_by_user(user_id,page = 1, per_page = 10)
    includes(:user,:dish,:c_users,:comment_votes)
      .where(user_id: user_id)
      .paginate(:page => page, :per_page => per_page)
  end

  def self.comment_by_id(id)
    includes(:user,:dish,:c_users).find_by_id(id)
  end

  def self.comment_by_id_by_user(user_id,id)
    includes(:user,:dish,:c_users,:comment_votes)
      .where(user_id: user_id).where(id: id).first
  end

  def self.comment_by_id_by_dish(dish_id,id)
    includes(:user,:dish,:c_users,:comment_votes)
      .where(dish_id: dish_id).where(id: id).first
  end

  def self.comments_with_votes_by_dish(dish_id,page = 1, per_page = 10)
    joins(:comment_votes).select("comments.*")
      .where(comment: {dish_id: dish_id})
      .group("comments.id")
      .paginate(:page => page, :per_page => per_page)
      .reorder("SUM(comment_votes.is_possitive) DESC")
  end

  belongs_to :user
  belongs_to :dish

  has_many :comment_votes, dependent: :destroy
  has_many :c_users, -> {reorder('name ASC, lastname ASC')} through: :comment_votes, source: :users

  validates :description, presence: true
  validates :description, length: { in: 10...250 }

end
