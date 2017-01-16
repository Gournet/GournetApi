class Order < ApplicationRecord
  include Utility
  default_scope {order("orders.day DESC")}
  scope :order_by_day, -> (ord) {order("orders.day #{ord}")}
  scope :order_by_price, -> (ord) {order("orders.price #{ord}")}
  scope :order_by_count, -> (ord) {order("orders.count #{ord}")}
  scope :order_by_estimated_time, -> (ord) {order("orders.estimated_time #{ord}")}
  scope :order_by_created_at, -> (ord) {order("orders.created_at #{ord}")}

  def self.load_orders(page = 1, per_page = 10)
    includes(:address,:user,:dish,:chef)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.order_by_id(id)
    includes(:address,:user,:dish,:chef)
    .find_by_id(id)
  end

  def self.orders_by_ids(ids,page = 1, per_page = 10)
    includes(:address,:user,:dish,:chef).where(id: ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.orders_by_not_ids(ids,page = 1, per_page = 10)
    includes(:address,:user,:dish,:chef)
    .where.not(id: ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.orders_by_user_id(user_id,page = 1, per_page = 10)
    includes(:address,:user,:dish,:chef)
    .where(user_id: user_id)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.orders_by_chef_id(chef_id,page = 1,per_page = 10)
    includes(:address,:user,:dish,:chef)
    .where(chef_id: chef_id)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.orders_by_dish_id(dish_id,page = 1, per_page = 10)
    includes(:address,:user,:dish,:chef)
    .where(dish_id: dish_id)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.orders_by_address_id(address_id, page = 1, per_page = 10)
    includes(:address,:user,:dish,:chef)
    .where(address_id: address_id)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.orders_today(page = 1,per_page = 10)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    Order.query_orders(range,page,per_page)
  end

  def self.orders_today_user(user,page = 1, per_page = 10)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    Order.query_orders_user(user,range,page,per_page)
  end

  def self.orders_today_chef(chef,page = 1, per_page = 10)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    Order.query_orders_chef(chef,range,page,per_page)
  end

  def self.orders_today_dish(dish, page = 1, per_page = 10)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    Order.query_orders_dish(dish,range,page,per_page)
  end

  def self.orders_yesterday(page = 1,per_page = 10)
    range = Order.new.yesterday()
    Order.query_orders(range,page,per_page)
  end

  def self.orders_yesterday_user(user,page = 1,per_page = 10)
    range = Order.new.yesterday
    Order.query_orders_user(user,range,page,per_page)
  end

  def self.orders_yesterday_chef(chef,page = 1,per_page = 10)
    range = Order.new.yesterday
    Order.query_orders_chef(chef,range,page,per_page)
  end

  def self.orders_yesterday_dish(dish,page = 1,per_page = 10)
    range = Order.new.yesterday
    Order.query_orders_dish(dish,range,page,per_page)
  end

  def self.orders_week(page = 1,per_page = 10)
    range = Order.new.week()
    Order.query_orders(range,page,per_page)
  end

  def self.orders_week_user(user,page = 1, per_page = 10)
    range = Order.new.week()
    Order.query_orders_user(user,range,page,per_page)
  end

  def self.orders_week_chef(chef,page = 1, per_page = 10)
    range = Order.new.week()
    Order.query_orders_chef(chef,range,page,per_page)
  end

  def self.orders_week_dish(dish,page = 1, per_page = 10)
    range = Order.new.week()
    Order.query_orders_dish(dish,range,page,per_page)
  end

  def self.orders_month(year = 2016,month_number = 1,page = 1,per_page = 10)
    range = Order.new.month(year,month_number)
    Order.query_orders(range,page,per_page)
  end

  def self.orders_month_user(user, year = 2016, month_number = 1,page = 1, per_page = 10)
    range = Order.new.month(year,month_number)
    Order.query_orders_user(user,range,page,per_page)
  end

  def self.orders_month_chef(chef, year = 2016, month_number = 1,page = 1, per_page = 10)
    range = Order.new.month(year,month_number)
    Order.query_orders_chef(chef,range,page,per_page)
  end

  def self.orders_month_dish(dish, year = 2016, month_number = 1,page = 1, per_page = 10)
    range = Order.new.month(year,month_number)
    Order.query_orders_dish(dish,range,page,per_page)
  end

  def self.orders_year(year_number = 2016,page = 1,per_page = 10)
    range = Order.new.year(year_number)
    Order.query_orders(range,page,per_page)
  end

  def self.orders_year_user(user,year_number = 2016, page = 1, per_page = 10)
    range = Order.new.year(year_number)
    Order.query_orders_user(user,range,page,per_page)
  end

  def self.orders_year_chef(chef,year_number = 2016, page = 1, per_page = 10)
    range = Order.new.year(year_number)
    Order.query_orders_chef(chef,range,page,per_page)
  end

  def self.orders_year_dish(dish,year_number = 2016, page = 1, per_page = 10)
    range = Order.new.year(year_number)
    Order.query_orders_dish(dish,range,page,per_page)
  end

  belongs_to :address
  belongs_to :user
  belongs_to :dish
  belongs_to :chef

  enum payment_type: {
    :card => 0,
    :cash => 1
  }

  validates :count,:price,:payment_type,:day,:estimated_time,presence:true
  validates :count,numericality: { greater_than_or_equal: 1 }
  validates :price,numericality: { greater_than_or_equal: 100 }
  validates :payment_type, presence: true
  validates :payment_type, inclusion: {in: payment_types.keys}

  protected
    def self.query_orders(range,page,per_page)
      includes(:address,:user,:dish,:chef)
        .where(day: range)
        .paginate(:page => page, :per_page => per_page)
    end

    def self.query_orders_user(user,range,page,per_page)
      includes(:address,:user,:dish,:chef)
        .where(day: range)
        .where(user_id: user)
        .paginate(:page => page, :per_page => per_page)
    end

    def self.query_orders_chef(chef,range,page,per_page)
      includes(:address,:user,:dish,:chef)
        .where(day: range)
        .where(chef_id: chef)
        .paginate(:page => page, :per_page => per_page)
    end

    def self.query_orders_dish(dish,range,page,per_page)
      includes(:address,:user,:dish,:chef)
        .where(day: range)
        .where(dish_id: dish)
        .paginate(:page => page, :per_page => per_page)
    end
end
