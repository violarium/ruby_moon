module CalendarHelper

  # Get string with month and year from date.
  def month_with_year(date)
    Date::MONTHNAMES[date.month].to_s + ', ' + date.year.to_s
  end
end