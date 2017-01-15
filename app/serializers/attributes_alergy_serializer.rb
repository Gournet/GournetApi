class AttributesAlergySerializer < ActiveModel::Serializer
  attributes :id,:name,:description
  attribute :status
  attribute :type

  def status
    "#{instance_options[:status_method]}"
  end

  def type
    "alergy"
  end

end
