class Chef < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User, Utility
  mount_uploader :avatar, AvatarUploader


  default_scope {order('chefs.name ASC, chefs.lastname ASC')}
  scope :order_by_email, -> (ord) {order("chefs.email #{ord}")}
  scope :order_by_username,  -> (ord) {order("chefs.username #{ord}")}
  scope :order_by_name,  -> (ord) {order("chefs.name #{ord}")}
  scope :order_by_lastname, -> (ord)  {order("chefs.lastname #{ord}")}
  scope :order_by_birthday, -> (ord) {order("chefs.birthday #{ord}")}
  scope :order_by_created_at,  -> (ord) {order("chefs.created_at #{ord}")}

  def self.load_chefs(page = 1, per_page = 10)
    includes(:dishes,:users,orders: [:user,:dish,:address])
      .paginate(:page => page, :per_page => per_page)
  end

  def self.chef_by_id(chef_id)
    includes(:dishes,:users,orders: [:user,:dish,:address])
      .find_by_id(chef_id)
  end

  def self.chefs_by_ids(chef_ids,page = 1, per_page = 10)
    includes(:dishes,:users,orders: [:user,:dish,:address])
      .where(id: chef_ids)
      .paginate(:page => page, :per_page => per_page)
  end

  def self.chefs_by_not_ids(chef_ids,page = 1, per_page = 10)
    includes(:dishes,:users,orders: [:user,:dish,:address])
      .where.not(id: chef_ids)
      .paginate(:page => page, :per_page => per_page)
  end

  def self.chefs_with_dishes(page = 1, per_page = 10)
    joins(:dishes).select("chefs.*")
      .group("chefs.id")
      .paginate(:page => page,:per_page => per_page)
      .reorder("COUNT(dishes.id) DESC")
  end

  def self.chefs_with_followers(page = 1, per_page = 10)
    joins(:followers).select("chefs.*")
      .group("chefs.id")
      .paginate(:page => page, :per_page => per_page)
      .reorder("COUNT(followers.user_id) DESC")
  end

  def self.chefs_with_orders(page = 1, per_page = 10)
    joins(:orders).select("chefs.*")
      .group("chefs.id")
      .paginate(:page => page, :per_page => per_page)
      .reorder("COUNT(orders.id) DESC")
  end

  def self.chefs_with_orders_today(page = 1,per_page = 10)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    Chef.query_orders(range,page,per_page)
  end

  def self.orders_today(chef)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    Chef.query_orders_chef(chef,range)
  end

  def self.chefs_with_orders_yesterday(page = 1, per_page = 10)
    range = Chef.new.yesterday()
    Chef.query_orders(range,page,per_page)
  end

  def self.orders_yesterday(chef)
    range = Chef.new.yesterday()
    Chef.query_orders_chef(chef,range)
  end

  def self.chefs_with_orders_week(page = 1,per_page = 10)
    range = Chef.new.week()
    Chef.query_orders(range,page,per_page)
  end

  def self.orders_week(chef)
    range = Chef.new.week()
    Chef.query_orders_chef(chef,range)
  end

  def self.chefs_with_orders_month(year = 2016,month_number = 1,page = 1,per_page = 10)
    range = Chef.new.month(year,month_number)
    Chef.query_orders(range,page,per_page)
  end

  def self.orders_month(chef, year = 2016, month_number = 1)
    range = Chef.new.month(year,month_number)
    Chef.query_orders_chef(chef,range)
  end

  def self.chefs_with_orders_year(year_number = 2016,page = 1, per_page = 10)
    range = Chef.new.year(year_number)
    Chef.query_orders(range,page,per_page)
  end

  def self.orders_year(chef,year_number = 2016)
    range = Chef.new.year(year_number)
    Chef.query_orders_chef(chef,range)
  end

  def self.best_seller_chefs_per_month(year = 2016,month_number = 1)
    range = Chef.new.month(year,month_number)
    best_seller_chefs(range)
  end

  def self.best_seller_chefs_per_year(year_number = 2016)
    range = Chef.new.year(year_number)
    best_seller_chefs(range)
  end

  has_many :dishes,-> {reorder('dishes.name ASC')}, dependent: :destroy
  has_many :followers, dependent: :destroy
  has_many :users,-> {reorder('users.name ASC, users.lastname ASC')}, through: :followers
  has_many :orders,-> {reorder('orders.created_at DESC')}, dependent: :nullify

  enum type_chef:{
    :profesional => 0,
    :amateur => 1,
    :especializado_en_catering => 2,
    :estudiante_de_cocina => 3,
    :otro => 4
  }
  validates :name,:username,:lastname,:birthday,:food_types,presence:true
  validates :name,:lastname, length: { minimum: 3 }
  validates :username,length: { minimum: 5 }, uniqueness:true
  validates_presence_of :avatar
  validates :email, presence:true, uniqueness: true
  validates :description, presence: true, length: {in:10...250}
  validates :food_types,length:{ minimum:3 }
  validates :type_chef, presence: true
  validates :expertise, length: {in: 10...250}
  validates :speciality, length: {in: 10...250}
  validates_format_of  :mobile, :with => /[0-9]{10,12}/x
  validate :validate_date?
  validates :type_chef, inclusion: {in: type_chefs.keys}
  validates_integrity_of :avatar
  validates_processing_of :avatar

  protected

    def self.query_orders(date,page,per_page)
      joins(:orders)
        .where(orders: {day: date})
        .group("chefs.id")
        .paginate(:page => page, :per_page => per_page)
        .reorder("count(orders.id)")
        .references(:orders)
    end

    def self.query_orders_chef(chef,date)
      includes(:dishes,:users,orders: [:dish,:user,:address])
        .where(orders: {day: date})
        .where(chefs: {id: chef})
        .reorder("orders.day")
        .references(:orders)
        .first
    end

    def self.best_seller_chefs(range)
      joins(:orders).select("chefs.*")
        .where(orders: { created_at: range })
        .group("chefs.id")
        .reorder("COUNT(orders.id) DESC")
        .limit(3)
    end

    def validate_date?
      unless Chronic.parse(:day)
        errors.add(:birthday, "is missing or invalid")
      end
    end

end
