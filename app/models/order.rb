class Order < ApplicationRecord

  default_scope {order("created_at DESC")}

  belongs_to :address
  belongs_to :user
  belongs_to :dish
  belongs_to :chef

  def self.load_orders
    includes(:address,:user,:dish,:chef)
  end

  def self.order_by_id(id)
    includes(:address,:user,:dish,:chef)
    .where(id: id)
    .first
  end

  def self.orders_by_user_id(user_id)
    includes(:address,:user,:dish,:chef)
    .where(user_id: user_id)
  end

  def self.orders_by_chef_id(chef_id)
    includes(:address,:user,:dish,:chef)
    .where(chef_id: chef_id)
  end

  def self.orders_by_dish_id(dish_id)
    includes(:address,:user,:dish,:chef)
    .where(dish_id: dish_id)
  end

  def self.orders_by_address_id(address_id)
    includes(:address,:user,:dish,:chef)
    .where(address_id: address_id)
  end

  def self.orders_today
    includes(:address,:user,:dish,:chef)
    .where(created_at: Date.today)
  end

  def self.orders_yesterday
    includes(:address,:user,:dish,:chef)
    .where(created_at: (Date.today - 1.days))
  end

  def self.orders_week
    today = Date.today
    next_week = Date.today
    if today.monday?
      next_week = (today + 6.days).end_of_day
    else
      today = previous_day(today,1)
      next_week = (today + 6.days).end_of_day
    end
    range = today..next_week
    includes(:address,:user,:dish,:chef)
    .where(created_at: range )
  end

  def self.orders_month(year,month)
    date = Data.new(year,month,1).beginning_of_day
    date_end = (data.end_of_month).end_of_day
    includes(:address,:user,:dish,:chef)
    .where(created_at: range)
  end

  def self.orders_month(year)
    date = Data.new(year,1,1).beginning_of_day
    date_end = (data.end_of_year).end_of_day
    includes(:address,:user,:dish,:chef)
    .where(created_at: range)
  end

  enum type_payment: {
    :card => 0,
    :cash => 1
  }

  validates :count,:price,:payment_type,presence:true
  validates :count,:numericality: { greater_than_or_equal: 1 }
  validates :price,:numericality: { greater_than_or_equal: 100 }
  validates :payment_type, presence: true
  validates_inclusion_of :payment_type, :in => type_payments.keys

end
