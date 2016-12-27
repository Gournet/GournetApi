class Availability < ApplicationRecord

  default_scope {order('day ASC, count DESC')}
  scope :today, -> { includes(:dish).where('day = ?', Date.today )}
  scope :tomorrow, -> { includes(:dish).where('day = ?' ,Date.tomorrow)}
  scope :week, -> { includes(:dish).where(day: (Date.today)..((Date.today + 6).end_of_day))}
  scope :available_for_today -> {today.where('count > 0')}

  belongs_to :dish

  validates :day,:end_time,:count,presence: true
  validates :count, numericality: { greater_than_or_equal_to: 0 }
  validate :validate_date?

  protected

  def validate_date?
    unless Chronic.parse(:day)
      errors.add(:day, "is missing or invalid")
    end
  end

end
