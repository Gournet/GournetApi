class AdminSerializer < ActiveModel::Serializer
  attributes :id,:name,:lastname,:username,:email,:mobile,:avatar,:provider,:uid
  attribute :type

  def type
    "admin"
  end
end
