class Chef < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User

  default_scope {order('name ASC, lastname ASC')}
  scope :order_by_email, -> {reorder('email ASC')}
  scope :order_by_username, -> {reorder('username ASC')}

  has_many :dishes,-> {reorder('name ASC')}, dependent: :destroy
  has_many :followers, dependent: :destroy
  has_many :users,-> {reorder('name ASC, lastname ASC')}, through: :followers
  has_many :orders,-> {reorder('created_at DESC')}, dependent: :nullify


  def self.load_chefs
    includes(:dishes,:users,orders: [:user,:dish,:address])
  end

  def self.chef_by_id(chef_id)
    includes(:dishes,:users,orders: [:user,:dish,:address])
      .where(id: id)
      .first
  end

  def self.orders_today(chef_id)
    includes(orders: [:user,:dish,:address])
      .where(orders: { created_at: Date.today })
      .where(id: chef_id)
  end

  def self.orders_yesterday(chef_id)
    includes(orders: [:user,:dish,:address])
      .where(orders: { created_at: (Date.today -1.days) })
      .where(id: chef_id)
  end

  def self.orders_week(chef_id)
    today = Date.today
    next_week = Date.today
    if today.monday?
      next_week = (today + 6.days).end_of_day
    else
      today = previous_day(today,1)
      next_week = (today + 6.days).end_of_day
    end
    range = today..next_week
    includes(orders: [:user,:dish,:address])
      .where(orders: { created_at: range } )
      .where(id: chef_id)
  end

  def self.orders_month(chef_id,year,month)
    date = Data.new(year,month,1).beginning_of_day
    date_end = (data.end_of_month).end_of_day
    range = date..next_week
    includes(orders: [:user,:dish,:address])
      .where(orders: { created_at: range } )
      .where(id: chef_id)
  end

  def self.orders_year(chef_id,year)
    date = Data.new(year,1,1).beginning_of_day
    date_end = (data.end_of_year).end_of_day
    range = date..next_week
    includes(orders: [:user,:dish,:address])
      .where(orders: { created_at: range } )
      .where(id: chef_id)
  end


  enum cooker:{
    :profesional => 0,
    :amateur => 1,
    :especializado_en_catering => 2,
    :estudiante_de_cocina => 3,
    :otro => 4
  }
  validates :name,:username,:lastname,:birthday,:food_types,presence:true
  validates :name,:lastname, length: { minimum: 3 }
  validates :username,length: { minimum: 5 }, uniqueness:true
  validates :avatar, presence: true
  validates :email, presence:true, uniqueness: true
  validates :description, presence: true, length: {in:10...250}
  validates :food_types,length:{ minimum:3 }
  validates :type_chef, presence: true
  validates :expertise, length: {in: 10...250}
  validates :speciality, length: {in: 10...250}
  validates_format_of  :mobile, :with => /[0-9]{10,12}/x
  validate :validate_date?
  validates_inclusion_of :type_chef, :in => cookers.keys


  protected

  def validate_date?
    unless Chronic.parse(:day)
      errors.add(:birthday, "is missing or invalid")
    end
  end

end
