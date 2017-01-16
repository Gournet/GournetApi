class AdminSerializer < ActiveModel::Serializer
  attributes :id,:name,:lastname,:username,:email,:mobile,:avatar,:provider,:uid,:type_chef,:speciality,:expertise
  attribute :type

  def type
    "admin"
  end
end
