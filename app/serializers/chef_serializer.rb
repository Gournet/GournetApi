class ChefSerializer < ActiveModel::Serializer
  attributes :id,:name,:lastname,:email,:uid,:provider,:mobile,:avatar,:food_types,:birthday,:speciality,:expertise,:type_chef
  attribute :type
  has_many :dishes
  has_many :users, key: :followers
  has_many :orders

  def type
    "chef"
  end

end
