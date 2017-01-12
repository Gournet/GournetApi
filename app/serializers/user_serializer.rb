class UserSerializer < ActiveModel::Serializer
  attributes :id,:name,:lastname,:email,:username,:mobile,:avatar,:birthday,:uid,:provider
  has_many :addresses
  has_many :alergies
  has_many :orders
  has_many :chefs
  has_many :dishes
  has_many :r_dishes
  has_many :c_dishes
  has_many :v_comments
end
