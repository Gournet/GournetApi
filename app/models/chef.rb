class Chef < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User
  enum cooker:{
    :Profesional => 0,
    :Amateur => 1,
    :Especializado_en_catering => 2,
    :Estudiante_de_cocina => 3,
    :otro => 4
  }
  validates :name,:username,:lastname,presence:true
  validates :name,:lastname, length: { minimum: 3 }
  validates :username,length: { minimum: 5 },uniqueness:true
  validates :avatar, presence: true
  validates :email, presence:true, uniqueness: true
  validates :description, presence: true, length: {in:10...250}
  validates :type, inclusion: cookers.keys
  validates :expertise, length: {in: 10...250}
  validates :speciality, length: {in: 10...250}
  validates_format_of  :mobile, :with => /[0-9]{10,12}/x

end
