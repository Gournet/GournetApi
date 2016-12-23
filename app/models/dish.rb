class Dish < ApplicationRecord
  belongs_to :chef
  has_many :category_by_dishes, dependent: :destroy
  has_many :categories, through: :category_by_dishes
  has_many :images
  has_many :orders, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :users, through: :comments
  has_many :alergy_by_dishes, dependent: :destroy
  has_many :alergies, through: :alergy_by_users
  has_many :favorite_dishes, dependent: :destroy
  has_many :users, through: :favorite_dishes
  has_many :rating_dishes, :dependent :destroy
  has_many :users, through: :rating_dishes
end
