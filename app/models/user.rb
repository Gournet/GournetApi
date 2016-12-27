class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User

  default_scope {order("name ASC, lastname ASC")}
  scope :order_by_email, -> {reorder("email ASC")}
  scope :order_by_username, -> {reorder("username ASC")}


  def self.load_users
    includes(:addresses,:alergies,:dishes,:chefs,orders: [:dish])
  end

  def self.user_by_id(id)
    includes(:addresses,:alergies,:dishes,:chefs,orders: [:dish])
    .where(id: id)
  end

  def self.orders_today(user_id)
    includes(orders: [:chef,:dish,:address])
      .where(orders: { created_at: Date.today })
      .where(id: user_id)
  end

  def self.orders_yesterday(user_id)
    includes(orders: [:chef,:dish,:address])
      .where(orders: { created_at: (Date.today -1.days) })
      .where(id: user_id)
  end

  def self.orders_week(user_id)
    today = Date.today
    next_week = Date.today
    if today.monday?
      next_week = (today + 6.days).end_of_day
    else
      today = previous_day(today,1)
      next_week = (today + 6.days).end_of_day
    end
    range = today..next_week
    includes(orders: [:chef,:dish,:address])
      .where(orders: { created_at: range } )
      .where(id: user_id)
  end

  def self.orders_month(user_id,year,month)
    date = Data.new(year,month,1).beginning_of_day
    date_end = (data.end_of_month).end_of_day
    range = date..next_week
    includes(orders: [:chef,:dish,:address])
      .where(orders: { created_at: range } )
      .where(id: user_id)
  end

  def self.orders_year(user_id,year)
    date = Data.new(year,1,1).beginning_of_day
    date_end = (data.end_of_year).end_of_day
    range = date..next_week
    includes(orders: [:chef,:dish,:address])
      .where(orders: { created_at: range } )
      .where(id: user_id)
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
  validates :avatar, presence: true
  validates :birthday,:mobile, presence: true
  validates_format_of :mobile, :with => /[0-9]{10,12}/x
  validate :validate_date?

  def set_password
    p = SecureRandom.urlsafe_base64(nil,false)
    self.password = p
    self.password_confirmation = p
  end

  def set_attributes(attribute)
    self.assign_attributes({
      name: attribute[:name],
      lastname: attribute[:lastname],
      avatar: attribute[:avatar],
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

end
