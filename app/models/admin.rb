class Admin < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User

  validates :name,:lastname,:username, presence: true
  validates :name, :lastname,length: {minimum: 3}
  validates :username, length: {minimum: 5} ,uniqueness:true
  validates :avatar, presence: true
  validates :email,presence: true,uniqueness:true
  validates :mobile, presence:true, uniqueness: true
  validates_format_of :mobile, :with => /[0-9]{10,12}/x
  
end
