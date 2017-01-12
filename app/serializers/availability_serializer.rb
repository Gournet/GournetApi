class AvailabilitySerializer < ActiveModel::Serializer
  attributes :id,:day,:end_time,:count
  belongs_to :dish
end
