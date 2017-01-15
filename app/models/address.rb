class Address < ApplicationRecord

  default_scope {order('addresses.created_at DESC')}

  def self.address_by_id(id)
    includes(:user,orders: [:dish,:chef])
    .find_by_id(id)
  end

  def self.load_addresses(page = 1, per_page = 10)
    includes(:user,orders: [:dish,:chef])
      .paginate(:page => page, :per_page => per_page)
  end

  def self.popular_addresses_by_orders_and_user(user_id,page = 1, per_page = 10)
    joins(:orders)
      .where(addresses: { user_id: user_id })
      .group("addresses.id")
      .paginate(:page => page,:per_page => per_page)
      .reorder("COUNT(orders.id) DESC")
    end

  def self.addresses_by_user(user_id,page = 1,per_page = 10)
    includes(orders: [:dish]).where(user_id: user_id)
      .paginate(:page => page, :per_page => per_page)
  end

  def self.address_by_lat_and_lng(lat,lng,page = 1,per_page = 10)
    includes(:user,orders: [:dish]).where(lat: lat)
      .where(lng: lng)
      .paginate(:page=>page,:per_page => per_page)
  end

  def self.addresses_with_orders(page = 1, per_page = 10)
    joins(:orders)
      .group("addresses.id")
      .paginate(:page => page,:per_page => per_page)
      .reorder("COUNT(orders.id) DESC")
  end

  belongs_to :user
  has_many :orders, -> {reorder('orders.created_at DESC')}, dependent: :nullify

  validates :address, :lat, :lng, presence: true
  validates :address, length: {minimum: 5}
  validates_format_of :lat,:lng, :with => /\d+\.\d{1,15}/x

end
