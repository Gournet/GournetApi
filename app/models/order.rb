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

  def self.orders_today
    includes(:address,:user,:dish,:chef)
    .where(created_at: Date.today)
  end

  def self.orders_by_user_by_dish_id(user_id,dish_id)
    where(dish_id: dish_id, user_id: user_id).first
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

  enum payment_type: {
    :card => 0,
    :cash => 1
  }

  validates :count,:price,:payment_type,presence:true
  validates :count,numericality: { greater_than_or_equal: 1 }
  validates :price,numericality: { greater_than_or_equal: 100 }
  validates :payment_type, presence: true
  validates :payment_type, inclusion: {in: payment_types.keys}

end
