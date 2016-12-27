class Category < ApplicationRecord

  default_scope {order('name ASC')}


  def self.search_name(name)
    includes(:dishes).where("name LIKE ?","#{name.downcase}%")
  end

  def self.category_by_id(id)
    includes(:dishes).where(id: id).first
  end

  def self.load_categories
    includes(:dishes)
  end

  has_many :category_by_dishes, dependent: :destroy
  has_many :dishes, -> {reorder('name ASC')}, through: :category_by_dishes

  validates :name,:description, presence: true
  validates :name, uniqueness: true
  validates :name, length: { minimum: 3 }
  validates :description, length: { in: 10...250 }

end
