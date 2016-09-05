# Critical period model.
#
# Belongs to user, have from and to field - Date types.
class CriticalPeriod
  include UserPeriodConcern

  embeds_many :critical_days

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


  # Get critical day vy date.
  #
  # @param date [Date]
  #
  # @return [CriticalDay]
  def critical_day_by_date(date)
    critical_days.to_a.find do |day|
      day.date == date
    end
  end


  # Cleanup critical days which are out of range.
  def cleanup_critical_days
    range = (from .. to)
    self.critical_days = critical_days.select { |day| range.include? day.date }
  end
end
