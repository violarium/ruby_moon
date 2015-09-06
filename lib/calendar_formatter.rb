# Formatter for calendar data.
class CalendarFormatter
  # 42 - 6 weeks - max amount of weeks in month. Needed for padding.
  DAYS_PER_MONTH = 42


  # Get month grid.
  #
  # @param date [Date] date object to build grid.
  #
  # @return [<Hash>]
  #   keys:
  #   * dates - Range of dates
  #   * month_date - Date object of first month day
  def month(date)
    first_month_day = date.beginning_of_month
    days_interval = month_days_interval(first_month_day)
    { month_date: first_month_day, dates: days_interval }
  end


  # Get one or more (amount) month grids.
  #
  # @param date [Date] date object from which month list will start.
  # @param limit [Integer] number of months in list.
  #
  # @return [Array<Hash>] array of hashes
  #   keys:
  #   * dates - Range of dates
  #   * month_date - Date object of first month day
  def month_list(date, limit: 1)
    month_list = []
    (0 ... limit).each { |t| month_list.push month(date + t.month) }
    month_list
  end


  private


  # Get month interval for month date.
  #
  # @param first_month_day [Date] first day of month.
  #
  # @return [Range] range between two dates.
  def month_days_interval(first_month_day)
    last_month_day = first_month_day.end_of_month

    first_week_day = first_month_day.beginning_of_week(:monday)
    last_week_day = last_month_day.end_of_week(:monday)

    while (last_week_day - first_week_day).to_i + 1 < DAYS_PER_MONTH
      last_week_day = last_week_day + 1.week
    end

    first_week_day .. last_week_day
  end
end