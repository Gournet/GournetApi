class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User,Utility
  mount_uploader :avatar, AvatarUploader

  default_scope {order("name ASC, lastname ASC")}
  scope :order_by_email, -> {reorder("email ASC")}
  scope :order_by_username, -> {reorder("username ASC")}


  def self.load_users(page = 1, per_page = 10)
    includes(:addresses,:alergies,:dishes,:chefs,orders: [:dish])
    .paginate(:page => page,:per_page => per_page)
  end

  def self.user_by_id(id)
    includes(:addresses,:alergies,:dishes,:chefs,orders: [:dish])
    .find_by_id(id)
  end

  def self.users_by_ids(ids,page = 1, per_page = 10)
    includes(:addresses,:alergies,:dishes,:chefs,orders: [:dish])
    .where(id: ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.users_by_not_ids(ids,page = 1, per_page = 10)
    includes(:addresses,:alergies,:dishes,:chefs,orders: [:dish])
    .where.not(id: ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.orders_today(user_id,page = 1, per_page = 10)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    User.query_orders(user_id,range,page,per_page)
  end

  def self.orders_yesterday(user_id,page = 1,per_page = 10)
    range = User.new.yesterday()
    User.query_orders(user_id,range,page,per_page)
  end

  def self.orders_week(user_id,page = 1, per_page = 10)
    range = User.new.week()
    User.query_orders(user_id,range,page,per_page)
  end

  def self.orders_month(user_id,year = 2016,month = 1,page = 1,per_page = 10)
    User.query_orders(user_id,range,page,per_page)
  end

  def self.orders_year(user_id,year = 2016,page = 1,per_page = 10)
    range = User.new.year(year)
    User.query_orders(user_id,range,page,per_page)
  end

  def self.users_with_addresses(page = 1, per_page = 10)
    joins(:addresses).select("users.*")
      .group("users.id")
      .paginate(:page => page, :per_page => per_page)
  end

  def self.users_with_alergies(page = 1, per_page = 10)
    joins(:alergies).select("users.*")
      .group("users.id")
      .paginate(:page => page, :per_page => per_page)
  end

  def self.users_with_followers(page = 1, per_page = 10)
    joins(:followers).select("users.*")
      .group("users.id")
      .paginate(:page => page, :per_page => per_page)
      .reorder("COUNT(followers.id) DESC")
  end

  def self.users_with_orders(page = 1, per_page = 10)
    joins(:orders).select("users.*")
      .group("users.id")
      .paginate(:page => page, per_page => per_page)
      .reorder("COUNT(orders.id) DESC")
  end

  def self.users_with_favorite_dishes(page = 1, per_page = 10)
    joins(:favorite_dishes).select("users.*")
      .group("users.id")
      .paginate(:page => page, :per_page => per_page)
      .reorder("COUNT(favorite_dishes.id) DESC")
  end

  def self.users_with_rating_dishes(page = 1, per_page = 10)
    joins(:favorite_dishes).select("users.*")
      .group("users.id")
      .paginate(:page => page, :per_page => per_page)
      reorder("COUNT(favorite_dishes)")
  end

  def self.users_with_orders_today(page = 1,per_page = 10)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    User.query_orders_users(range,page,per_page)
  end

  def self.users_with_orders_yesterday(page = 1, per_page = 10)
    range = User.new.yesterday()
    User.query_orders_users(range,page,per_page)
  end

  def self.users_with_orders_week(page = 1,per_page = 10)
    range = User.new.week()
    User.query_orders_users(range,page,per_page)
  end

  def self.users_with_orders_month(year = 2016,month_number = 1,page = 1,per_page = 10)
    range = User.new.month(year,month_number)
    User.query_orders_users(range,page,per_page)
  end

  def self.users_with_orders_year(year_number = 2016)
    range = User.new.year(year_number)
    User.query_orders_users(range,page,per_page)
  end

  def self.best_seller_users_per_year(year_number = 2016)
    range = User.new.year(year_number)
    joins(:orders).select("users.*")
      .where(orders: { created_at: range })
      .group("users.id")
      .reorder("COUNT(orders.id) DESC")
      .limit(3)
  end


  has_many :addresses, -> {order('created_at DESC')}, dependent: :destroy
  has_many :alergy_by_users, dependent: :destroy
  has_many :alergies,-> {order{'name ASC'}}, through: :alergy_by_users
  has_many :orders, -> {order{'created_at DESC'}}, dependent: :nullify
  has_many :followers, dependent: :destroy
  has_many :chefs, -> {order('name ASC')}, through: :followers
  has_many :favorite_dishes, dependent: :destroy
  has_many :dishes, -> {order('name ASC')}, through: :favorite_dishes
  has_many :rating_dishes, ->{order('rating DESC')}, dependent: :nullify
  has_many :r_dishes,->{order('name ASC')}, through: :rating_dish, source: :dishes


  validates :name, :lastname, presence: true
  validates :name, :lastname, length: { minimum: 2 }
  validates :email,:username, presence: true, uniqueness: true
  validates :username, length: { minimum: 2 }
  validates_presence_of :avatar
  validates :birthday,:mobile, presence: true
  validates_format_of :mobile, :with => /[0-9]{10,12}/x
  validate :validate_date?
  validates_integrity_of :avatar
  validates_processing_of :avatar

  def set_password
    p = SecureRandom.urlsafe_base64(nil,false)
    self.password = p
    self.password_confirmation = p
  end

  def set_attributes(attribute)
    self.assign_attributes({
      name: attribute[:name],
      lastname: attribute[:lastname],
      remote_avatar_url: attribute[:avatar],
      username: attribute[:username],
      birthday: attribute[:birthday],
      mobile: attribute[:mobile],
      email: "#{attribute[:username]}@facebook.com"
    })
    self.skip_confirmation!

  end
  def set_token
    client_id = SecureRandom.urlsafe_base64(nil, false)
    token     = SecureRandom.urlsafe_base64(nil, false)

    self.tokens[client_id] = {
      token: BCrypt::Password.create(token),
      expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
    }
    new_auth_header = self.build_auth_header(token, client_id)
    new_auth_header
  end

  protected

  def validate_date?
    unless Chronic.parse(:day)
      errors.add(:birthday, "is missing or invalid")
    end
  end

  def self.query_orders_users(date,page,per_page)
    joins(:orders).select("users.*")
      .where(orders: { created_at: date })
      .group("users.id")
      .paginate(:page => page, :per_page => per_page)
      .reorder("COUNT(orders.id) DESC")
  end

  def self.query_orders(user_id,date,page,per_page)
    includes(orders: [:chef,:dish,:address])
      .where(orders: { created_at: date } )
      .where(id: user_id)
      .paginate(:page => page, :per_page => per_page)
  end

end
