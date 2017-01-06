class Dish < ApplicationRecord
  include Utility

  default_scope {order('name ASC')}
  scope :order_by_price, -> {reorder('price ASC')}
  scope :order_by_calories, -> {reorder('calories ASC')}
  scope :order_by_cooking_time, -> {reorder('cooking_time ASC')}
  scope :order_by_rating, -> {reorder('rating DESC')}


  def self.popular_dishes_by_rating(page = 1, per_page = 10)
    where("rating >= 3")
    .paginate(:page => page, :per_page => per_page)
    .reorder("rating DESC")
  end

  def self.dishes_with_rating(page = 1, per_page = 10)
    joins(:rating_dishes).select('dishes.*')
      .group("dishes.id")
      .paginate(:page => page, :per_page => per_page)
      .reorder("AVG(rating_dishes.rating) DESC")
  end

  def self.dishes_with_comments(page = 1, per_page = 10)
    joins(:comments).select("dishes.*")
      .group("dishes.id")
      .paginate(:page => page ,:per_page => per_page)
      .reorder("COUNT(comments.id) DESC")
  end

  def self.dihses_with_rating_and_comments(page = 1, per_page = 10)
    joins(:rating_dishes,:comments).select('dishes.*')
      .group("dishes.id")
      .paginate(:page => page, :per_page => 10)
      .reorder("AVG(rating_dishes.rating) DESC, COUNT(comments.id) DESC")
  end

  def self.popular_dishes_by_orders(page = 1, per_page = 10)
    joins(:orders).select("dishes.*")
      .group("dishes.id")
      .paginate(:page => page,:per_page => per_page)
      .reorder("COUNT(orders.dish_id) DESC")
  end

  def self.popular_dishes_by_orders_today(page = 1, per_page = 10)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    Dish.query_orders(range,page,per_page)
  end

  def self.popular_dishes_by_orders_yesterday(page = 1, per_page = 10)
    range = Dish.new.yesterday()
    Dish.query_orders(range,page,per_page)
  end

  def self.popular_dishes_by_orders_week(page = 1, per_page = 10)
    range = Dish.new.week()
    Dish.query_orders(range,page,per_page)
  end

  def self.popular_dishes_by_orders_month(year = 2016, month_number = 1, page = 1, per_page = 10)
    range = Dish.new.month(year,month_number)
    Dish.query_orders(range,page,per_page)
  end

  def self.popular_dishes_by_orders_year(year_number = 2016,page = 1, per_page = 10)
    range = Dish.new.year(year_number)
    Dish.query_orders(range,page,per_page)
  end
  def self.best_seller_dishes_per_year(year_number = 2016)
    range = Dish.new.year(year_number)
    joins(:orders).select("dishes.*")
      .where(orders: { created_at: range })
      .group("dishes.id")
      .reorder("COUNT(orders.id) DESC")
      .limit(3)
  end

  def self.dish_by_id(id)
    includes(:images,:chef,:categories,orders: [:user,:address],:comments,:alergies,:users)
    .find_by_id(id)
  end

  def self.dishes_by_ids(sids,page = 1,per_page = 10)
    includes(:images,:categories,orders: [:user,:address],:comments,:alergies,:users)
    .where(id: ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.dishes_by_not_ids(ids,page = 1,per_page = 10)
    includes(:images,:categories,orders: [:user,:address],:comments,:alergies,:users)
    .where.not(id: ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.load_dishes(page = 1, per_page = 10)
    includes(:images,:categories,orders: [:user,:address],:comments,:alergies,:users)
    .paginate(:page => page, :per_page => per_page)
  end

  belongs_to :chef
  has_many :category_by_dishes, dependent: :destroy
  has_many :categories, through: :category_by_dishes
  has_many :images, -> {reorder('order ASC')}, dependent: :destroy
  has_many :orders, -> {reorder('created_at DESC')}, dependent: :nullify
  has_many :availabilities, dependent: :destroy
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

    def self.query_orders(date,page,per_page)
      dishes = joins(:orders).select("dishes.*")
        .where(orders: {created_at: date })
        .group("dishes.id")
        .paginate(:page => page, :per_page => per_page)
        .reorder("COUNT(orders.dish_id) DESC")
    end
end
