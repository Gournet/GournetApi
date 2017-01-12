class Alergy < ApplicationRecord

    default_scope {order('alergies.name ASC')}

    def self.search_name(name,page = 1,per_page = 10)
      includes(:dishes,:users).where("alergies.name LIKE ?", "#{name.downcase}%")
        .paginate(:page => page, :per_page => per_page)
    end

    def self.alergy_by_id(id)
      includes(:dishes,:users).find_by_id(id)
    end

    def self.alergies_by_ids(ids,page = 1, per_page = 10)
      includes(:dishes,:users).where(id: ids)
        .paginate(:page => page, :per_page => per_page)
    end

    def self.alergies_by_not_ids(ids,page = 1, per_page = 10)
      includes(:dishes,:users).where.not(id: ids)
        .paginate(:page => page, :per_page => per_page)
    end

    def self.load_alergies(page = 1,per_page = 10)
      includes(:dishes,:users)
        .paginate(:page => page, :per_page => per_page)
    end

    def self.alergies_with_users(page = 1,per_page = 10)
      joins(:alergy_by_users).select("alergies.*")
        .group("alergies.id")
        .paginate(:page => page,:per_page => per_page)
        .reorder("COUNT(alergy_by_users.user_id) DESC")
    end

    def self.alergies_with_dishes(page = 1,per_page = 10)
      joins(:alergy_by_dishes).select("alergies.*")
        .group("alergies.id")
        .paginate(:page => page,:per_page => per_page)
        .reorder("COUNT(alergy_by_dishes.dish_id) DESC")
    end

    def self.alergies_with_dishes_and_users(page = 1, per_page = 10)
      joins(:alergy_by_dishes,:alergy_by_users).select("alergies.*")
        .group("alergies.id")
        .paginate(:page => page, :per_page => per_page)
        .reorder("COUNT(alergy_by_dishes.dish_id) DESC, COUNT(alergy_by_users.user_id) DESC")
    end

    has_many :alergy_by_users, dependent: :destroy
    has_many :users, -> {reorder('users.name ASC, users.lastname ASC')}, through: :alergy_by_users
    has_many :alergy_by_dishes, dependent: :destroy
    has_many :dishes, -> {reorder('dishes.name ASC')}, through: :alergy_by_dishes

    validates :name, :description, presence: true
    validates :name, uniqueness: true
    validates :name, length: { minimum: 3 }
    validates :description, length: { in: 10...250 }

end
