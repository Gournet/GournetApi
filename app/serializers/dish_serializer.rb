class DishSerializer < ActiveModel::Serializer
  attributes :id,:name,:description,:price,:cooking_time,:calories,:rating
  belongs_to :chef
  has_many :categories
  has_many :images
  has_many :orders
  has_many :availabilities
  has_many :comments
  has_many :alergies
  has_many :users
  has_many :rating_users
end
