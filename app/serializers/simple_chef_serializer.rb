class SimpleChefSerializer < ActiveModel::Serializer
  attributes :id,:name,:lastname,:email,:uid,:provider,:mobile,:avatar,:food_types,:birthday,:speciality,:expertise,:type_chef
  attribute :follower_count
  attribute :dish_count
  attribute :order_count
  attribute :type

  def follower_count
    object.users.count
  end

  def dish_count
    object.dishes.count
  end

  def order_count
    object.orders.count
  end

  def type
    "chef"
  end
end
