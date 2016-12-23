class Order < ApplicationRecord

  belongs_to :address
  belongs_to :user
  belongs_to :dish
  belongs_to :chef

  enum type: {
    :Card => 0,
    :Cash => 1
  }

  validates :count,:price,:payment_type,presence:true
  validates :count,:numericality: { greater_than_or_equal: 1 }
  validates :price,:numericality: { greater_than_or_equal: 100 }
  validates :payment_type, inclusion: types.keys

end
