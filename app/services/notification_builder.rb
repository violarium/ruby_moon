# Notification builder.
# It needed to rebuild user notifications on some changes.
class NotificationBuilder
  # Rebuild notifications for user. It will delete old ones.
  #
  # @param user [User]
  def rebuild_for(user)
    user.future_critical_periods.all.each do |future_period|
      future_period.notifications.delete_all
      create_for_period(user, future_period)
    end
  end


  private


  # Create notifications for future critical period.
  #
  # @param user [User]
  # @param future_period [FutureCriticalPeriod]
  def create_for_period(user, future_period)
    user.notify_before.each do |days_before|
      time = Time.find_zone(user.time_zone).local(future_period.from.year,
                                                  future_period.from.month,
                                                  future_period.from.day,
                                                  user.notify_at) + days_before.days
      future_period.notifications.create!(time: time)
    end
  end
end