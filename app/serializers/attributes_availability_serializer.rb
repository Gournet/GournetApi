class AttributesAvailabilitySerializer < ActiveModel::Serializer
  attributes :id,:day,:end_time,:count
  attribute :type
  attribute :status
  belongs_to :dish_id

  def type
    "availability"
  end

  def status
    "#{instance_options[:status_method]}"
  end
  
end
