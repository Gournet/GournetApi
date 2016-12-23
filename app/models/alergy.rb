class Alergy < ApplicationRecord

    has_many :alergy_by_users, dependent: :destroy
    has_many :users, through: :alery_by_users
    has_many :alergy_by_dishes, dependent: :destory
    has_many :dishes, through: :alergy_by_dishes

    validates :name, :description, presence: true
    validates :name, :uniqueness: true
    validates :name, length: { minimum: 3 }
    validates :description : { in: 10...250 }

end
