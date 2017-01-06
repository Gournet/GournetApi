class Availability < ApplicationRecord
  # When we use scope, we get an active record relationsip for that reason we can continue
  # chaining more methods on the result, I mean pagination, so the pagination of this model will be made
  # in the controller instead of the model
  default_scope {order('day ASC, count DESC')}
  scope :today, -> { includes(:dish).where('day = ?', Date.today )}
  scope :tomorrow, -> { includes(:dish).where('day = ?' ,Date.tomorrow)}
  scope :next_six_days, -> { includes(:dish).where(day: (Date.today)..((Date.today + 6).end_of_day))}
  scope :available_for_today, -> {today.where('count > 0')}

  def self.availabilities_by_dish(dish_id,page = 1,per_page = 10)
    includes(:dish)
      .where(dish_id: dish_id)
      .paginate(:page => page, :per_page => per_page)
  end

  def self.availability_by_id(id)
    includes(:dish)
      .find_by_id(id)
  end

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
