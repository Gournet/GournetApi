class FavoriteDish < ApplicationRecord
  belongs_to :user
  belongs_to :dish

  def self.add_favorite(user,dish)
    fav = find_or_initialize_by(user_id: user,dish_id: dish)
    fav.save
  end

  def self.remove_favorite(user,dish)
    fav = where(user_id: user).where(dish_id: dish).first
    if fav
      fav.destroy
    end
    fav
  end
end
