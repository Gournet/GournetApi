class AddressSerializer < ActiveModel::Serializer
  attributes :address,:lat,:lng
  has_many :orders
  belongs_to :user
end
