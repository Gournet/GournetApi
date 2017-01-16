class SimpleAlergySerializer < ActiveModel::Serializer
  attributes :id,:name,:description
  attribute :user_count
  attribute :dish_count
  attribute :type

  def user_count
    object.users.count
  end

  def dish_count
    object.dishes.count
  end

  def type
    "alergy"
  end

end
