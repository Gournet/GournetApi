class Admin < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User

  default_scope {order('name ASC, lastname ASC')}
  scope :order_by_username, -> {reorder('username ASC')}
  scope :order_by_email, -> {reorder('email ASC')}

  def self.admin_by_id(id)
    find_by_id(id)
  end

  def self.admin_by_username(username)
    where(username: username).first
  end

  def self.admin_by_email(email)
    where(email: email).first
  end

  validates :name,:lastname,:username, presence: true
  validates :name, :lastname,length: {minimum: 3}
  validates :username, length: {minimum: 5} ,uniqueness:true
  validates :avatar, presence: true
  validates :email,presence: true,uniqueness:true
  validates :mobile, presence:true, uniqueness: true
  validates_format_of :mobile, :with => /[0-9]{10,12}/x

end
