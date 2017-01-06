class Image < ApplicationRecord

  mount_uploader :image, ImageUploader
  default_scope {order("created_at DESC")}


  def self.images_by_dish_id(dish_id, page = 1, per_page = 10)
    includes(:dish).where(dish_id: dish_id)
    .paginate(:page => page, :per_page => per_page)
    .reorder("order ASC")
  end

  def self.load_images(page = 1, per_page = 10)
    includes(:dish)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.images_by_dish(dish_id, page = 1, per_page  = 10)
    includes(:dish)
      .where(dish_id: dish_id)
      .paginate(:page => page ,:per_page => per_page)
  end

  def self.image_by_id(id)
    includes(:dish).where(id: id).first
  end

  belongs_to :dish

  validates :description,:order,:image,presence:true
  validates :description,length: { in: 10...250 }
  validates :order, numericality: { greater_than_or_equal: 0 }
  validates_presence_of :image
  validates_integrity_of :image
  validates_processing_of :image



end
