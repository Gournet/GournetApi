class RatingDish < ApplicationRecord

  default_scope {order("created_at DESC")}
  after_save :update_rating_dish

  belongs_to :user
  belongs_to :dish


  validates :rating, presence: true
  #validates :rating, :in => 0..5
  validates_inclusion_of :rating, :in => 0..5

  def self.add_rating(user_id,dish_id,rating)
    new_rating = find_or_initialize_by(user_id: user_id,dish_id: dish_id)
    new_rating.rating = rating
    new_rating.save
  end

  def self.rating_by_dishes(ids)
    where(:dish_id => ids).group(:dish_id).reorder("avg(rating) DESC").average(:rating)
  end

  def self.load_rating
    group(:dish_id).reorder("avg(rating) DESC").average(:rating)
  end

  private
    def update_rating_dish
      dish = Dish.find_by_id(self.dish_id)
      dish.rating = RatingDish.rating_by_dishes([self.dish_id])[self.dish_id]
      dish.save
    end

end
