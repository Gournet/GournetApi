class Alergy < ApplicationRecord
    has_many :alergy_by_users, dependent: :destroy
    has_many :users, through: :alery_by_users
    has_many :alergy_by_dishes, dependent: :destory
    has_many :dishes, through: :alergy_by_dishes
end
