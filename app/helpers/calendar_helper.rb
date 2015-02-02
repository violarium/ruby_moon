module CalendarHelper
  # Get string with month and year from date.
  def month_with_year(date)
    t('date.month_names')[date.month] + ', ' + date.year.to_s
  end
end