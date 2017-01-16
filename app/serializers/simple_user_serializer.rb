class SimpleUserSerializer < ActiveModel::Serializer
  attributes :id,:name,:lastname,:email,:username,:mobile,:avatar,:birthday,:uid,:provider
  attribute :type
  attribute :address_count
  attribute :alergy_count
  attribute :order_count
  attribute :favorite_chef_count
  attribute :favorite_dish_count

  def type
    "user"
  end

  def address_count
    object.addresses.count
  end

  def alergy_count
    object.alergies.count
  end

  def order_count
    object.orders.count
  end

  def favorite_dish_count
    object.dishes.count
  end

  def favorite_chef_count
    object.chefs.count
  end
  
end
