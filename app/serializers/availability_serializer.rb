class AvailabilitySerializer < ActiveModel::Serializer
  attributes :id,:day,:end_time,:count
  attribute :type
  belongs_to :dish

  def type
    "availability"
  end
end
