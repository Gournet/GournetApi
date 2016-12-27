class Dish < ApplicationRecord

  default_scope {order('name ASC')}
  scope :order_by_price, -> {reorder('price ASC')}
  scope :order_by_calories, -> {reorder('calories ASC')}
  scope :order_by_cooking_time, -> {reorder('cooking_time ASC')}


  def self.order_by_rating
    dishes = joins(:rating_dishes).select('dishes.*')
      .group("dishes.id")
      .having("AVG(rating_dishes.rating) >= 1")
      .reorder("AVG(rating_dishes.rating) DESC")
  end

  def self.popular_dishes_by_rating
    dishes = joins(:rating_dishes).select('dishes.*')
      .group("dishes.id")
      .having("AVG(rating_dishes.rating) >= 1")
      .reorder("AVG(rating_dishes.rating) DESC")
      .limit(10)
    dishes
  end

  def self.popular_dishes_by_orders
    dishes = joins(:orders).select("dishes.*")
      .group("dishes.id")
      .reorder("COUNT(orders.dish_id) DESC")
      .limit(10)
  end

  def self.popular_dishes_by_orders_yesterday
    date_start = (Date.today.midnight - 1.days)
    date_end =  ((Date.today. - 1.days).end_of_day)
    dishes = joins(:orders).select("dishes.*")
      .where("orders.created_at => ? AND orders.created_at <= ? ",date_start,date_end)
      .group("dishes.id")
      .reorder("COUNT(orders.dish_id) DESC")
      .limit(10)
  end

  def self.popular_dishes_by_orders_week
    today = Date.today
    next_week = Date.today
    if today.monday?
      next_week = (today + 6.days).end_of_day
    else
      today = previous_day(today,1)
      next_week = (today + 6.days).end_of_day
    end
    dishes = joins(:orders).select("dishes.*")
      .where("orders.created_at => ? AND orders.created_at <= ? ",today,next_week)
      .group("dishes.id")
      .reorder("COUNT(orders.dish_id) DESC")
      .limit(10)
  end

  def self.dish_by_id(:id)
    includes(:images,:categories,:orders,:comments,:alergies,:users).where(id: id).first
  end

  def self.load_dishes
    includes(:images,:categories,:orders,:comments,:alergies,:users)
  end

  belongs_to :chef
  has_many :category_by_dishes, dependent: :destroy
  has_many :categories, through: :category_by_dishes
  has_many :images, -> {reorder('order ASC')}, dependent: :destroy
  has_many :orders, -> {reorder('created_at DESC')}, dependent: :nullify
  has_many :comments, -> {reorder('created_at DESC')}, dependent: :destroy
  has_many :comment_users, -> {reorder('created_at DESC')}, through: :comments, source: :users
  has_many :alergy_by_dishes, dependent: :destroy
  has_many :alergies, -> {reorder('name ASC')}, through: :alergy_by_users
  has_many :favorite_dishes, dependent: :destroy
  has_many :users, -> {reorder('name ASC, lastname ASC')}, through: :favorite_dishes
  has_many :rating_dishes, -> {order('rating DESC')}, dependent: :destroy
  has_many :rating_users, -> {reorder('name ASC, lastname ASC')}, through: :rating_dishes, source: :users

  validates :name,:description,:price,:cooking_time,:calories,presence:true
  validates :name,length: { minimum: 3 }
  validates :description, length: { in: 10...250 }
  validates :price,numericality: { greater_than_or_equal: 100 }
  validates :cooking_time,numericality: { greater_than: 1 }
  validates :calories,numericality: { greater_than: 0 }

  protected
    def previous_day(date,day_of_week)
      date - ((date.wday - day_of_week) % 7)
    end

end
