module DataProvider
  class UserCalendar
    # Create calendar data provider for user.
    #
    # @param user [User]
    def initialize(user)
      @user = user
      @calendar_formatter = Calendar::CalendarFormatter.new
    end


    # Get month grid data.
    #
    # @param month_date [Date]
    #
    # @return [Hash]
    def month_grid_data(month_date)
      month_data = @calendar_formatter.month(month_date)

      date_from = month_data[:dates].first
      date_to = month_data[:dates].last

      critical_dates = collect_period_dates(@user.critical_periods, date_from, date_to)
      future_critical_dates = collect_period_dates(@user.future_critical_periods, date_from, date_to)

      { month: month_data, critical_dates: critical_dates, future_critical_dates: future_critical_dates }
    end


    # Get info about the day from params.
    #
    # @param params [Hash]
    #
    # @return [Hash]
    def day_info(params)
      date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      {
          date: date,
          current_period: @user.critical_periods.has_date(date).first,
          closest_period: @user.critical_periods.near_by_date(date).first,
      }
    end


    private

    # Collect the dates for period from query.
    #
    # @param query
    # @param date_from [Date]
    # @param date_to [Date]
    #
    # @return [Array]
    def collect_period_dates(query, date_from, date_to)
      dates = []
      periods = query.between_dates(date_from, date_to).all.to_a
      periods.each do |period|
        (period.from .. period.to).each do |date|
          dates.push(date) if date >= date_from && date <= date_to
        end
      end

      dates
    end
  end
end