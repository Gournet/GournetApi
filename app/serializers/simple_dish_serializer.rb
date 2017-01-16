class SimpleDishSerializer < ActiveModel::Serializer
  attributes :id,:name,:description,:price,:cooking_time,:calories,:rating
  attribute :type
  attribute :category_count
  attribute :image_count
  attribute :order_count
  attribute :availability_count
  attribute :alergy_count
  attribute :favorite_user_count
  attribute :rating_user_count

  belongs_to :chef_id

  def category_count
    object.categories.count
  end

  def image_count
    object.images.count
  end

  def order_count
    object.orders.count
  end

  def availability_count
    object.availabilities.count
  end

  def favorite_users_count
    object.users.count
  end

  def rating_user_count
    object.rating_users.count
  end

  def type
    "dish"
  end
end
