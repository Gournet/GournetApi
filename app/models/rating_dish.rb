class RatingDish < ApplicationRecord

  belongs_to :user
  belongs_to :dish

  validates :rating, presence: true
  validates :rating, :in => 0..5 
end
