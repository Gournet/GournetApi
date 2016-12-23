class Address < ApplicationRecord

  belongs_to :user
  has_many :oders, dependent: :nullify

  validates :address, :lat, :lng, presence: true, uniqueness: true
  validates :address, length: {minimum: 5}
  validates_format_of :lat,:lng, :with => /\d+\.\d{1,15}/x

end
