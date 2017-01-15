class AddressSerializer < ActiveModel::Serializer
  attributes :address,:lat,:lng,:id
  attribute :type
  has_many :orders
  belongs_to :user

  def type
    "address"
  end
end
