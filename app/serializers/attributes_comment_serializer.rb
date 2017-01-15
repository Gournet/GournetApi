class AttributesCommentSerializer < ActiveModel::Serializer
  attributes :id,:description
  attribute :type
  attribute :status

  def type
    "comment"
  end

  def status
    "#{instance_options[:status_method]}"
  end
end
