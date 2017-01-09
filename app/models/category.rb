class Category < ApplicationRecord

  default_scope {order('categories.name ASC')}


  def self.search_name(name,page = 1,per_page = 10)
    includes(:dishes).where("name LIKE ?","#{name.downcase}%")
      .paginate(:page => page, :per_page => per_page)
  end

  def self.category_by_id(id)
    includes(:dishes).find_by_id(id)
  end

  def self.categories_by_ids(ids,page,per_page)
    includes(:dishes).where(id: ids)
      .paginate(:page => page, :per_page => per_page)
  end
  def self.categories_by_not_ids(ids,page,per_page)
    includes(:dishes).where.not(id: ids)
      .paginate(:page => page, :per_page => per_page)
  end

  def self.load_categories(page = 1,per_page = 10)
    includes(:dishes)
      .paginate(:page => page,:per_page => per_page)
  end

  def self.categories_with_dishes(page = 1,per_page = 10)
    joins(:category_by_dishes).select("categories.*")
      .group("categories.id")
      .paginate(:page => page, :per_page => per_page)
      .reorder("COUNT(category_by_dishes.dish_id) DESC")
  end

  has_many :category_by_dishes, dependent: :destroy
  has_many :dishes, -> {reorder('dishes.name ASC')}, through: :category_by_dishes

  validates :name,:description, presence: true
  validates :name, uniqueness: true
  validates :name, length: { minimum: 3 }
  validates :description, length: { in: 10...250 }

end
