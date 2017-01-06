class Address < ApplicationRecord

  default_scope {order('created_at DESC')}

  def self.orders_from_address(id)
    includes(orders: [:dish]).find_by_id(id)
  end

  def self.address_from_lat_and_lng(lat,lng,page = 1,per_page = 10)
    includes(:user,:orders: [:dish]).where(lat: lat)
      .where(lng: lng)
      .paginate(:page=>page,:per_page)
  end

  belongs_to :user
  has_many :orders, -> {reorder('created_at DESC')}, dependent: :nullify

  validates :address, :lat, :lng, presence: true
  validates :address, length: {minimum: 5}
  validates_format_of :lat,:lng, :with => /\d+\.\d{1,15}/x

end
