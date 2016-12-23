class Address < ApplicationRecord
  belongs_to :user
  has_many :oders, dependent: :nullify
end
