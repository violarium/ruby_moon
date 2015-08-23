# Critical period model.
class CriticalPeriod
  include UserPeriodConcern

  # Append date to period and all the dates between.
  #
  # @param date [Date]
  def append_date(date)
    if date < from
      self.from = date
    elsif date > to
      self.to = date
    end
  end
end
