class RatingDish < ApplicationRecord

  default_scope {order("created_at DESC")}

  belongs_to :user
  belongs_to :dish

  validates :rating, presence: true
  #validates :rating, :in => 0..5
  validates_inclusion_of :rating, :in => 0..5

  def self.rating_by_dishes(ids)
    where(:dish_id => ids).group(:dish_id).reorder("avg(rating) DESC").average(:rating)
  end

  def self.load_rating
    group(:dish_id).reorder("avg(rating) DESC").average(:rating)
  end
  
end
