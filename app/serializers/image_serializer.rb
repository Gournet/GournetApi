class ImageSerializer < ActiveModel::Serializer
  attributes :id,:image,:description,:order
  attribute :type
  belongs_to :dish

  def type
    "image"
  end

end
