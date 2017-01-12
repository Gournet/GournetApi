class ChefSerializer < ActiveModel::Serializer
  attributes :id,:name,:lastname,:email,:uid,:provider,:mobile,:avatar,:food_types,:birthday,:speciality,:expertise
  has_many :dishes
  has_many :users
  has_many :orders
end
