class Image < ApplicationRecord

  default_scope {order("created_at DESC")}


  def self.images_by_dish_id(dish_id)
    includes(:dish).where(dish_id: dish_id).reorder("order ASC")
  end

  def self.load_images
    includes(:dish)
  end

  def self.image_by_id(id)
    includes(:dish).where(id: id).first
  end

  belongs_to :dish

  validates :description,:order,:image,presence:true
  validates :description,length: { in: 10...250 }
  validates :order, numericality: { greater_than_or_equal: 0 }


end
