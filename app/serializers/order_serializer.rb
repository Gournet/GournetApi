class OrderSerializer < ActiveModel::Serializer
  attributes :id,:count,:price,:payment_type,:day,:estimated_time
  belongs_to :address
  belongs_to :user
  belongs_to :dish
  belongs_to :user
end
