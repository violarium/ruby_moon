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
    # @param limit [Integer]
    # @param current_date [Date]
    #
    # @return [Hash]
    def month_grid_data(month_date, limit: 1, current_date: nil)
      month_list = @calendar_formatter.month_list(month_date, limit: limit)

      date_from = month_list[0][:dates].first
      date_to = month_list[-1][:dates].last
      critical_dates = Repository::CriticalPeriod.date_collection(@user, date_from, date_to)

      { month_list: month_list,
        critical_dates: critical_dates,
        current_date: current_date,
        month_date: month_date }
    end
  end
end