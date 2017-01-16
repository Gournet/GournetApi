class Dish < ApplicationRecord
  include Utility

  default_scope {order('dishes.name ASC')}
  scope :order_by_name, -> (ord) {order("dishes.name #{ord}")}
  scope :order_by_price,  -> (ord) {order("dishes.price #{ord}")}
  scope :order_by_calories, -> (ord) {order("dishes.calories #{ord}")}
  scope :order_by_cooking_time, -> (ord) {order("dishes.cooking_time #{ord}")}
  scope :order_by_rating, -> (ord) {order("dishes.rating #{ord}")}
  scope :order_by_created_at, -> (ord) {order("dishes.created_at #{ord}")}

  def self.popular_dishes_by_rating(rating = 2,page = 1, per_page = 10)
    includes(:images,:chef,:categories,:alergies,:users,:comments,:comment_users,:rating_users,:availabilities,orders: [:user,:chef,:address])
      .where(rating: rating)
      .paginate(:page => page, :per_page => per_page)
      .reorder("dishes.rating DESC")
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

  def self.dishes_with_orders(page = 1, per_page = 10)
    joins(:orders).select("dishes.*")
      .group("dishes.id")
      .paginate(:page => page,:per_page => per_page)
      .reorder("COUNT(orders.dish_id) DESC")
  end

  def self.dishes_by_orders_today(page = 1, per_page = 10)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    Dish.query_orders(range,page,per_page)
  end

  def self.orders_today(dish)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    Dish.query_orders_dish(dish,range)
  end

  def self.dishes_by_orders_yesterday(page = 1, per_page = 10)
    range = Dish.new.yesterday()
    Dish.query_orders(range,page,per_page)
  end

  def self.orders_yesterday(dish)
    range = Dish.new.yesterday()
    Dish.query_orders_dish(dish,range)
  end

  def self.dishes_by_orders_week(page = 1, per_page = 10)
    range = Dish.new.week()
    Dish.query_orders(range,page,per_page)
  end

  def self.orders_week(dish)
    range = Dish.new.week()
    Dish.query_orders_dish(dish,range)
  end

  def self.dishes_by_orders_month(year = 2016, month_number = 1, page = 1, per_page = 10)
    range = Dish.new.month(year,month_number)
    Dish.query_orders(range,page,per_page)
  end

  def self.orders_month(dish,year,month_number)
    range = Dish.new.month(year,month_number)
    Dish.query_orders_dish(dish,range)
  end

  def self.dishes_by_orders_year(year_number = 2016,page = 1, per_page = 10)
    range = Dish.new.year(year_number)
    Dish.query_orders(range,page,per_page)
  end

  def self.orders_year(dish,year_number)
    range = Dish.new.year(year_number)
    Dish.query_orders_dish(dish,range)
  end

  def self.best_seller_dishes_per_month(year = 2016, month_number = 1)
    range = Dish.new.month(year,month_number)
    Dish.best_seller(range)
  end

  def self.best_seller_dishes_per_year(year_number = 2016)
    range = Dish.new.year(year_number)
    Dish.best_seller(range)
  end

  def self.dish_by_id(id)
    includes(:images,:chef,:categories,:alergies,:users,:comments,:comment_users,:rating_users,:availabilities,orders: [:user,:chef,:address])
    .find_by_id(id)
  end

  def self.dishes_by_ids(ids,page = 1,per_page = 10)
    includes(:images,:chef,:categories,:alergies,:users,:comments,:comment_users,:rating_users,:availabilities,orders: [:user,:chef,:address])
    .where(id: ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.dishes_by_not_ids(ids,page = 1,per_page = 10)
    includes(:images,:chef,:categories,:alergies,:users,:comments,:comment_users,:rating_users,:availabilities,orders: [:user,:chef,:address])
    .where.not(id: ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.load_dishes(page = 1, per_page = 10)
    includes(:images,:chef,:categories,:alergies,:users,:comments,:comment_users,:rating_users,:availabilities,orders: [:user,:chef,:address])
    .paginate(:page => page, :per_page => per_page)
  end

  def self.dish_by_chef(chef,page = 1,per_page = 10)
    includes(:images,:chef,:categories,:alergies,:users,:comments,:comment_users,:rating_users,:availabilities,orders: [:user,:chef,:address])
      .where(dishes: {chef_id: chef})
      .paginate(:page => page, :per_page => per_page)
  end

  belongs_to :chef
  has_many :category_by_dishes, dependent: :destroy
  has_many :categories, through: :category_by_dishes
  has_many :images, -> {reorder('images.order ASC')}, dependent: :destroy
  has_many :orders, -> {reorder('orders.created_at DESC')}, dependent: :nullify
  has_many :availabilities, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :comment_users, through: :comments, source: :user
  has_many :alergy_by_dishes, dependent: :destroy
  has_many :alergies, -> {reorder('alergies.name ASC')}, through: :alergy_by_dishes
  has_many :favorite_dishes, dependent: :destroy
  has_many :users, -> {reorder('users.name ASC, users.lastname ASC')}, through: :favorite_dishes
  has_many :rating_dishes, dependent: :destroy
  has_many :rating_users, through: :rating_dishes, source: :user

  validates :name,:description,:price,:cooking_time,:calories,presence:true
  validates :name,length: { minimum: 3 }
  validates :description, length: { in: 10...250 }
  validates :price,numericality: { greater_than_or_equal: 100 }
  validates :cooking_time,numericality: { greater_than: 1 }
  validates :calories,numericality: { greater_than: 0 }

  protected
    def self.best_seller(range)
      joins(:orders).select("dishes.*")
        .where(orders: { created_at: range })
        .group("dishes.id")
        .reorder("COUNT(orders.id) DESC")
        .limit(3)
    end

    def self.query_orders(date,page,per_page)
      includes(:images,:chef,:categories,:alergies,:users,:comments,:comment_users,:rating_users,:availabilities,orders: [:user,:chef,:address])
        .where(orders: { day: date})
        .group("dishes.id")
        .paginate(:page => page, :per_page => per_page)
        .reorder("COUNT(orders.id) DESC")
        .references(:orders)
    end

    def self.query_orders_dish(dish,date)
      includes(:images,:chef,:categories,:alergies,:users,:comments,:comment_users,:rating_users,:availabilities,orders: [:user,:chef,:address])
        .where(orders: { day: date })
        .where(dishes: { id: dish })
        .reorder("orders.day")
        .references(:orders)
        .first
    end

end
