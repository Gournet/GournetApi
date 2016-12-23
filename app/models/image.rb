class Image < ApplicationRecord

  belongs_to :chef

  validates :description,:order,:image,presence:true
  validates :description,length: { in: 10...250 }
  validates :order, numericality: { greater_than_or_equal: 0 }
  

end
