require 'Date'
module Utility
  def yesterday
    date_start = (Date.today - 1.days).beginning_of_day
    date_end =  ((Date.today. - 1.days).end_of_day)
    range = date_start..date_end
  end

  def week
    today = Date.today
    next_week = Date.today
    if today.monday?
      next_week = (today + 6.days).end_of_day
    else
      today = Chef.previous_day(today,1)
      next_week = (today + 6.days).end_of_day
    end
    range = today..next_week
  end

  def previous_day(date,day_of_week)
    date - ((date.wday - day_of_week) % 7)
  end

  def month(year,month_number)
    date = Date.new(year,month_number,1).beginning_of_day
    date_end = (date.end_of_month).end_of_day
    range = date..date_end
  end

  def year(year_number)
    date = Date.new(year_number,1,1).beginning_of_day
    date_end = (date.end_of_year).end_of_day
    range = date..date_end
  end

  
end
