class Category < ApplicationRecord
  has_many :category_by_dishes, dependent: :destroy
  has_many :dishes, through: :dishes
end
