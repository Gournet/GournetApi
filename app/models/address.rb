class Address < ApplicationRecord

  default_scope {order('created_at DESC')}

  def self.orders_from_address(id)
    includes(orders: [:dish]).where(id: id).first
  end

  def self.address_from_lat_and_lng(lat,lng)
    includes(:user,:orders: [:dish]).where(lat: lat)
      .where(lng: lng)
  end

  belongs_to :user
  has_many :orders, -> {reorder('created_at DESC')}, dependent: :nullify

  validates :address, :lat, :lng, presence: true
  validates :address, length: {minimum: 5}
  validates_format_of :lat,:lng, :with => /\d+\.\d{1,15}/x

end
