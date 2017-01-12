class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User,Utility
  mount_uploader :avatar, AvatarUploader

  default_scope {order("users.name ASC, users.lastname ASC")}
  scope :order_by_email, -> {reorder("users.email ASC")}
  scope :order_by_username, -> {reorder("users.username ASC")}


  def self.search(text,page = 1,per_page = 10)
    where("email LIKE ? OR username LIKE ?", "#{text.downcase}%", "#{text.downcase}%")
      .paginate(:page => page, :per_page => per_page)
  end

  def self.load_users(page = 1, per_page = 10)
    includes(:comments,:addresses,:alergies,:dishes,:chefs,orders: [:dish,:chef])
    .paginate(:page => page,:per_page => per_page)
  end

  def self.user_by_id(id)
    includes(:comments,:addresses,:alergies,:dishes,:chefs,orders: [:dish,:chef])
    .find_by_id(id)
  end

  def self.users_by_ids(ids,page = 1, per_page = 10)
    includes(:comments,:addresses,:alergies,:dishes,:chefs,orders: [:dish,:chef])
    .where(id: ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.users_by_not_ids(ids,page = 1, per_page = 10)
    includes(:comments,:addresses,:alergies,:dishes,:chefs,orders: [:dish,:chef])
    .where.not(id: ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.orders_today(page = 1, per_page = 10)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    User.query_orders(range,page,per_page)
  end

  def self.orders_today_user(user)
    range = Date.today.beginning_of_day..Date.today.end_of_day
    User.query_orders_user(user,range)
  end

  def self.orders_yesterday(page = 1,per_page = 10)
    range = User.new.yesterday()
    User.query_orders(range,page,per_page)
  end

  def self.orders_yesterday_user(user)
    range = User.new.yesterday()
    User.query_orders_user(user,range)
  end

  def self.orders_week(page = 1, per_page = 10)
    range = User.new.week()
    User.query_orders(range,page,per_page)
  end

  def self.orders_week_user(user)
    range = User.new.week()
    User.query_orders_user(user,range)
  end

  def self.orders_month(year = 2016,month_number = 1,page = 1,per_page = 10)
    range = User.new.month(year,month_number)
    User.query_orders(range,page,per_page)
  end

  def self.orders_month_user(user,year = 2016,month_number = 1)
    range = User.new.month(year,month_number)
    User.query_orders_user(user,range)
  end

  def self.orders_year(year_number = 2016,page = 1,per_page = 10)
    range = User.new.year(year_number)
    User.query_orders(range,page,per_page)
  end

  def self.orders_year_user(user,year_number = 2016)
    range = User.new.year(year_number)
    User.query_orders_user(user,range)
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
    joins(:rating_dishes).select("users.*")
      .group("users.id")
      .paginate(:page => page, :per_page => per_page)
      .reorder("COUNT(rating_dishes.id)")
  end

  def self.best_seller_users_per_month(year = 2016,month_number = 1)
    range = User.new.month(year,month_number)
    User.best_seller(range)
  end

  def self.best_seller_users_per_year(year_number = 2016)
    range = User.new.year(year_number)
    User.best_seller(range)
  end


  has_many :addresses, -> {reorder('addresses.created_at DESC')}, dependent: :destroy
  has_many :alergy_by_users, dependent: :destroy
  has_many :alergies,-> {reorder('alergies.name ASC')}, through: :alergy_by_users
  has_many :orders, -> {reorder('orders.created_at DESC')}, dependent: :nullify
  has_many :followers, dependent: :destroy
  has_many :chefs, -> {reorder('chefs.name ASC')}, through: :followers
  has_many :favorite_dishes, dependent: :destroy
  has_many :dishes, -> {reorder('dishes.name ASC')}, through: :favorite_dishes
  has_many :rating_dishes, dependent: :nullify
  has_many :r_dishes, through: :rating_dishes, source: :dish
  has_many :comments, dependent: :destroy
  has_many :c_dishes, through: :comments, source: :dish
  has_many :comment_votes, dependent: :nullify
  has_many :v_comments, ->{reorder('comments.created_at DESC')}, through: :comment_votes, source: :comment


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

  def self.best_seller(range)
    joins(:orders).select("users.*")
      .where(orders: { created_at: range })
      .group("users.id")
      .reorder("COUNT(orders.id) DESC")
      .limit(3)
  end

  def self.query_orders(date,page,per_page)
    includes(orders: [:dish, :chef, :address])
      .where(orders: { day: date } )
      .group("users.id")
      .paginate(:page => page, :per_page => per_page)
      .reorder("COUNT(orders.id) DESC")
      .references(:orders)
  end

  def self.query_orders_user(user,date)
    includes(orders: [:dish, :chef, :address])
      .where(users: { id: user})
      .where(orders: { day: date } )
      .reorder("orders.day DESC")
      .references(:orders)
      .first
  end

end
