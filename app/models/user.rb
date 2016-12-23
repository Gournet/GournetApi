class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User

  has_many :addresses, dependent: :destroy
  has_many :alergy_by_users, dependent: :destroy
  has_many :alergies, through: :alergy_by_users
  has_many :orders, dependent: :nullify
  has_many :followers, dependent: :destroy
  has_many :chefs, through: :followers
  has_many :favorite_dishes, dependent: :destroy
  has_many :dishes, through: :favorite_dishes
  has_many :rating_dishes, dependent: :nullify
  has_many :dishes, through: :rating_dish


  validates :name, :lastname, presence: true
  validates :name, :lastname, length: { minimum: 2 }
  validates :email,:username, presence: true, uniqueness: true
  validates :username, length: { minimum: 2 }
  validates :avatar, presence: true
  validates :birthday,:mobile, presence: true
  validates_format_of :mobile, :with => /[0-9]{10,12}/x

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

end
