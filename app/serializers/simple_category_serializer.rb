class SimpleCategorySerializer < ActiveModel::Serializer
  attributes :id,:name,:description
  attribute :type
  attribute :dish_count

  def type
    "alergy"
  end

  def dish_count
    object.dishes.count
  end

end
