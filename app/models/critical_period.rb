# Critical period model.
#
# Belongs to user, have from and to field - Date types.
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
