class ImageSerializer < ActiveModel::Serializer
  attributes :id,:image,:description,:order
  belongs_to :dish
end
