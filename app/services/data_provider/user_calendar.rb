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
      critical_dates = Repository::CriticalPeriod.date_collection(@user, date_from, date_to)

      { month: month_data, critical_dates: critical_dates }
    end
  end
end