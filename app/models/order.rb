class Order < ApplicationRecord
  include Utility
  default_scope {order("orders.day DESC")}

  belongs_to :address
  belongs_to :user
  belongs_to :dish
  belongs_to :chef

  def self.load_orders(page = 1, per_page = 10)
    includes(:address,:user,:dish,:chef)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.order_by_id(id)
    includes(:address,:user,:dish,:chef)
    .find_by_id(id)
  end

  def self.orders_by_ids(ids,page = 1, per_page = 10)
    includes(:address,:user,:dish,:chef)
    .where(ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.orders_by_not_ids(ids,page = 1, per_page = 10)
    includes(:address,:user,:dish,:chef)
    .where.not(ids)
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


  def self.orders_yesterday(page = 1,per_page = 10)
    range = Order.new.yesterday()
    Order.query_orders(range,page,per_page)
  end

  def self.orders_week(page = 1,per_page = 10)
    range = Order.new.week()
    Order.query_orders(range,page,per_page)
  end

  def self.orders_month(page = 1,per_page = 10,year,month_number)
    range = Order.new.month(year,month_number)
    Order.query_orders(range,page,per_page)
  end

  def self.orders_year(year_number,page = 1,per_page = 10)
    range = Order.new.year(year_number)
    Order.query_orders(range,page,per_page)
  end

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
end
