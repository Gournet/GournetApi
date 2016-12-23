class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :dish

  validates :description, :is_possitive, presence: true
  validates :description, length: { in: 10...250 }
  validates_inclusion_of :is_possitive, :in => -1..1
  
end
