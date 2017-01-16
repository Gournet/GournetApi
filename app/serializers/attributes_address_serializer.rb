class AttributesAddressSerializer < ActiveModel::Serializer
  attributes :address,:lat,:lng,:id
  attribute :status
  attribute :type

  def status
    "#{instance_options[:status_method]}"
  end

  def type
    "address"
  end
end
