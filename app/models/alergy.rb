class Alergy < ApplicationRecord

    default_scope {order('name ASC')}

    def self.search_name(name)
      includes(:dishes,:users).where("name LIKE ?," "#{name.downcase}%")
    end

    def self.alergy_by_id(id)
      includes(:dishes,:users).where(id: id).first
    end

    def load_alergies
      includes(:dishes,:users)
    end

    has_many :alergy_by_users, dependent: :destroy
    has_many :users, -> {reorder('name ASC, lastname ASC')}, through: :alery_by_users
    has_many :alergy_by_dishes, dependent: :destory
    has_many :dishes -> {reorder('name ASC')}, through: :alergy_by_dishes

    validates :name, :description, presence: true
    validates :name, :uniqueness: true
    validates :name, length: { minimum: 3 }
    validates :description : { in: 10...250 }

end
