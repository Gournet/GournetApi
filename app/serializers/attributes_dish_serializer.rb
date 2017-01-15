class AttributesDishSerializer < ActiveModel::Serializer
  attributes :id,:name,:description,:price,:cooking_time,:calories,:rating
  attribute :type
  belongs_to :chef_id
  
  def type
    "dish"
  end
  def status
    "#{instance_options[:status_method]}"
  end
end
