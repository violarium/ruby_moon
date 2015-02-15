module CalendarHelper
  # Get title for date, including month and year.
  #
  # @param date [Date] date object to get title.
  #
  # @return [String] title.
  def month_date_title(date)
    t('date.month_names')[date.month] + ', ' + date.year.to_s
  end


  # Get title for date, including date, month and year.
  #
  # @param date [Date] date object to get title.
  #
  # @return [String] title.
  def full_date_title(date)
    date.day.to_s + ' ' + month_date_title(date)
  end


  # Make calendar day url from date object.
  #
  # @param date [Date] date object to create url.
  #
  # @return [String] url string.
  def make_calendar_day_url(date)
    calendar_day_url(date.year, date.month, date.day)
  end


  # Get additional classes for day in calendar.
  #
  # @param date [Date]
  # @param date_index [Integer]
  # @param current_month_date [Date]
  # @param critical_dates [Array<Dates>]
  #
  # @param [String]
  def calendar_day_opt_classes(date, date_index, current_month_date, critical_dates)
    css_classes = []
    css_classes.push "week-day-number-#{date_index % 7}"
    css_classes.push "week-number-#{date_index / 7}"
    css_classes.push 'inactive' if date.month != current_month_date.month
    css_classes.push 'critical' if critical_dates.include? date

    css_classes.join(' ')
  end
end