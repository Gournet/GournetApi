class AddressSerializer < ActiveModel::Serializer
  attributes :address,:lat,:lng,:id
  has_many :orders
  belongs_to :user
end
