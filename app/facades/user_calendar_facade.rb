class UserCalendarFacade
  # Create calendar data provider for user.
  #
  # @param user [User]
  def initialize(user)
    @user = user
    @calendar_formatter = CalendarFormatter.new
  end


  # Get info about month.
  #
  # @param month_date [Date]
  #
  # @return [Hash]
  def month_info(month_date, current_date)
    month_data = @calendar_formatter.month(month_date)
    dates = []

    month_data[:dates].each do |date|
      dates.push(date: date)
    end
    date_from = month_data[:dates].first
    date_to = month_data[:dates].last

    critical_periods = @user.critical_periods.between_dates(date_from, date_to).all
    future_critical_periods = @user.future_critical_periods.between_dates(date_from, date_to).all

    critical_dates = periods_dates(critical_periods, date_from, date_to)
    future_critical_dates = periods_dates(future_critical_periods, date_from, date_to)
    critical_days = periods_critical_days(critical_periods, date_from, date_to)

    dates.each do |date_note|
      date_key = date_note[:date].to_s
      date_note[:is_critical] = critical_dates.has_key?(date_key)
      date_note[:is_future_critical] = future_critical_dates.has_key?(date_key)
      if critical_days.has_key?(date_key)
        critical_day_value = critical_days[date_key].value
      else
        critical_day_value = nil
      end
      date_note[:critical_day_value] = critical_day_value
    end

    {
      current_date: current_date,
      month_date: month_data[:month_date],
      dates: dates,
      upcoming_period: @user.upcoming_critical_period(current_date),
    }
  end


  # Get info about the day from params.
  #
  # @param date [Date]
  #
  # @return [Hash]
  def day_info(date)
    {
        date: date,
        current_period: @user.critical_periods.has_date(date).first,
        close_periods: @user.critical_periods.near_by_date(date).all.to_a,
    }
  end


  private


  # Get hash of critical days for periods.
  #
  # @param periods [Array]
  # @param date_from [Date]
  # @param date_to [Date]
  #
  # @return [Hash]
  def periods_critical_days(periods, date_from, date_to)
    critical_days = {}
    periods.each do |period|
      period.critical_days.each do |critical_day|
        if critical_day.date >= date_from && critical_day.date <= date_to
          critical_days[critical_day.date.to_s] = critical_day
        end
      end
    end
    critical_days
  end


  # Get hash of periods dates.
  #
  # @param periods [Array]
  # @param date_from [Date]
  # @param date_to [Date]
  #
  # @return [Hash]
  def periods_dates(periods, date_from, date_to)
    periods_dates = {}
    periods.each do |period|
      (period.from .. period.to).each do |date|
        periods_dates[date.to_s] = true if date >= date_from && date <= date_to
      end
    end
    periods_dates
  end
end
