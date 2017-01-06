class CategoryByDish < ApplicationRecord
  belongs_to :category
  belongs_to :dish
end
