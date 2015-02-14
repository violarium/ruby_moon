module Calendar
  # Formatter for calendar data.
  class CalendarFormatter
    # 42 - 6 weeks - max amount of weeks in month. Needed for padding.
    DAYS_PER_MONTH = 42


    # Get one or more (amount) months.
    # @param date [Date] date object from which month list will start.
    # @param limit [Integer] number of months in list.
    #
    # @return [Array<Hash>] array of hashes
    #   keys:
    #   * dates - Range of dates
    #   * month_date - Date object of first month day
    #   * week_days - Array of week day names
    def month_list(date, limit: 1)
      first_month_day = date.beginning_of_month

      month_list = []
      (0 ... limit).each do |t|
        current_first_day = first_month_day + t.month
        month_list.push(dates: month_days_interval(current_first_day),
                        month_date: current_first_day,
                        week_days: week_days_sequence)
      end
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


    # Get sequence of week names.
    #
    # @return [Array]
    def week_days_sequence
      # Sort just in case
      ::Date::DAYS_INTO_WEEK.keys.sort_by { |week_string| ::Date::DAYS_INTO_WEEK[week_string] }
    end
  end
end