module Repository
  # Repository to work with critical periods.
  class CriticalPeriod
    # Returns array of critical dates for user within dates range.
    #
    # @param user [User] object of user.
    # @param date_from [Date] date from.
    # @param date_to [Date] date to.
    #
    # @return [Array] array of dates
    #
    # @example
    #   CriticalPeriod.date_collection(Use.find(10), Date.new(2014, 1). Date.today)
    def self.date_collection(user, date_from, date_to)
      critical_dates = []

      critical_periods = user.critical_periods.or({:from.gte => date_from, :to.lte => date_to},
                                                  {:from.lte => date_from, :to.gte => date_to},
                                                  {:from.lte => date_from, :to.gte => date_from},
                                                  {:from.lte => date_to, :to.gte => date_to}).all.to_a
      critical_periods.each do |period|
        (period.from .. period.to).each do |date|
          critical_dates.push(date) if date >= date_from && date <= date_to
        end
      end

      critical_dates
    end
  end
end