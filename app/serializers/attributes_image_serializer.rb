class AttributesImageSerializer < ActiveModel::Serializer
  attributes :id,:image,:description,:order
  attribute :type
  attribute :status
  belongs_to :dish_id

  def type
    "image"
  end

  def status
    "#{instance_options[:status_method]}"
  end
end
