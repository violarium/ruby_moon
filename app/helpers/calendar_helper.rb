module CalendarHelper
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
  # @param month_info [Hash]
  #
  # @return [String]
  def calendar_day_opt_classes(date, date_index, month_info)
    css_classes = []
    css_classes.push "week-day-number-#{date_index % 7}"
    css_classes.push "week-number-#{date_index / 7}"
    css_classes.push 'inactive' if date[:date].month != month_info[:month_date].month
    css_classes.push 'critical' if date[:is_critical]
    css_classes.push 'future-critical' if date[:is_future_critical]
    css_classes.push 'current-day' if month_info[:current_date] == date[:date]

    css_classes.join(' ')
  end


  # Get localized period string.
  #
  # @param period
  #
  # @return [String] localized period string.
  def localized_period(period)
    from_day = l(period.from, format: :full_day)
    to_day = l(period.to, format: :full_day)
    "#{from_day} - #{to_day}"
  end
end