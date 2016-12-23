class Availability < ApplicationRecord

  belongs_to :dish

  validates :day,:end_time,:count,presence: true
  validates :count, numericality: { greater_than: 0 }
  validate :validate_date?

  protected

  def validate_date?
    unless Chronic.parse(:day)
      errors.add(:day, "is missing or invalid")
    end
  end

end
