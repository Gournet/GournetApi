class Category < ApplicationRecord

  has_many :category_by_dishes, dependent: :destroy
  has_many :dishes, through: :dishes

  validates :name,:description, presence: true
  validates :name, uniqueness: true
  validates :name, length: { minimum: 3 }
  validates :description, length: { in: 10...250 }

end
