class AttributesOrderSerializer < ActiveModel::Serializer
  attributes :id,:count,:price,:payment_type,:day,:estimated_time
  attribute :type
  attribute :status, if: :is_created?

  belongs_to :address_id
  belongs_to :user_id
  belongs_to :dish_id
  belongs_to :user_id

  def type
    "order"
  end

  def is_created?
    instance_options[:status_method] == "Created"
  end

  def status
    "#{instance_options[:status_method]}"
  end

end
