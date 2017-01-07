class Admin < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User
  mount_uploader :avatar, AvatarUploader

  default_scope {order('name ASC, lastname ASC')}
  scope :order_by_username, -> {reorder('username ASC')}
  scope :order_by_email, -> {reorder('email ASC')}

  def self.admin_by_id(id)
    find_by_id(id)
  end

  def self.load_admins(page = 1, per_page = 10)
    all
    .paginate(:page => page, :per_page => per_page)
  end

  def self.admins_by_ids(ids)
    where(id:ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.admins_by_not_ids(ids,page = 1, per_page = 10)
    where.not(id:ids)
    .paginate(:page => page, :per_page => per_page)
  end

  def self.admin_by_username(username)
    where(username: username).first
  end

  def self.admin_by_email(email)
    where(email: email).first
  end

  def self.search(text,page = 1,per_page = 10)
    where("email LIKE ? OR username LIKE ?", "#{text.downcase}%", "#{text.downcase}%")
      .paginate(:page => page, :per_page => per_page)
  end

  validates :name,:lastname,:username, presence: true
  validates :name, :lastname,length: {minimum: 3}
  validates :username, length: {minimum: 5} ,uniqueness:true
  validates_presence_of :avatar
  validates :email,presence: true,uniqueness:true
  validates :mobile, presence:true, uniqueness: true
  validates_format_of :mobile, :with => /[0-9]{10,12}/x
  validates_integrity_of :avatar
  validates_processing_of :avatar

end
