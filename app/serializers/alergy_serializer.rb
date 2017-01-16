class AlergySerializer < ActiveModel::Serializer
  attributes :id,:name,:description
  attribute :type
  has_many :users
  has_many :dishes

  def type
    "alergy"
  end
end
