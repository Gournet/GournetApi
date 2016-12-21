class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable,:omniauthable
  include DeviseTokenAuth::Concerns::User

  validates :name, :lastname, presence: true
  validates :name, :lastname, length: { minimum: 2 }
  validates :email,:username, presence: true, uniqueness: true
  validates :username, length: { minimum: 2 }
  validates :avatar, presence: true
  validates :birthday,:mobile, presence: true
  validates :mobile, uniqueness: true
  validates_format_of :mobile, :with => /[0-9]{10,12}/x
end
