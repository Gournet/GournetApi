class OrderSerializer < ActiveModel::Serializer
  attributes :id,:count,:price,:payment_type,:day,:estimated_time
  attribute :type

  belongs_to :address
  belongs_to :user
  belongs_to :dish
  belongs_to :chef

  def type
    "order"
  end
end
