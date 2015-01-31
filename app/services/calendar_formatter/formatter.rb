module CalendarFormatter
  class Formatter
    # 42 - 6 weeks - max amount of weeks in month. Needed for padding.
    DAYS_PER_MONTH = 42

    # Month list
    # Get one or more (amount) months, formatted in way of weeks.
    def month_list(date, amount: 1)
      month_list = []
      (0 ... amount).each do |t|
        first_date = date + t.month
        month_list.push({ first_date: first_date,
                          dates: month_interval(first_date),
                          week: week_sequence })
      end

      { date_from: month_list[0][:dates].first,
        date_to: month_list[-1][:dates].last,
        month_list: month_list }
    end


    private

    # Get month interval for date (day means nothing).
    def month_interval(date)
      first_day = date.beginning_of_month
      last_day = date.end_of_month

      first_week_day = first_day.beginning_of_week(:monday)
      last_week_day = last_day.end_of_week(:monday)

      while (last_week_day - first_week_day).to_i + 1 < DAYS_PER_MONTH
        last_week_day = last_week_day + 1.week
      end

      first_week_day .. last_week_day
    end

    # Get sequence of week names
    def week_sequence
      # Sort just in case
      ::Date::DAYS_INTO_WEEK.keys.sort_by { |week_string| ::Date::DAYS_INTO_WEEK[week_string] }
    end
  end
end