class Admin < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User
  mount_uploader :avatar, AvatarUploader

  default_scope {order('admins.name ASC, admins.lastname ASC')}
  scope :order_by_username, -> (ord) {order("admins.username #{ord}")}
  scope :order_by_email, -> (ord) {order("admins.email #{ord}")}
  scope :order_by_name, -> (ord) {order("admins.name #{ord}")}
  scope :order_by_lastname, -> (ord) {order("admins.lastname")}
  scope :order_by_created_at, -> (ord) {order("admins.created_at")}

  def self.admin_by_id(id)
    find_by_id(id)
  end

  def self.load_admins(page = 1, per_page = 10)
    paginate(:page => page, :per_page => per_page)
  end

  def self.admins_by_ids(ids, page = 1 ,per_page = 10)
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
