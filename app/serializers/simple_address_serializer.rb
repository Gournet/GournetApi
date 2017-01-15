class SimpleAddressSerializer < ActiveModel::Serializer
  attributes :address,:lat,:lng,:id
  attribute :type
  has_many :orders, key: :orders_count do
    object.orders.count
  end
  belongs_to :user_id

  def type
    "address"
  end
end
