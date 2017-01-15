class CategorySerializer < ActiveModel::Serializer
  attributes :id,:name,:description
  attribute :type
  has_many :dishes

  def type
    "category"
  end
  
end
