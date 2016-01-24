# Notification builder.
# It needed to rebuild user notifications on some changes.
class NotificationBuilder

  # Rebuild notifications for user. It will delete old ones.
  #
  # @param user [User]
  def rebuild_for(user)
    current_time = Time.current
    user.future_critical_periods.all.each do |future_period|
      times = get_notification_times(future_period, user.time_zone, user.notify_before, user.notify_at)
      clean_for_period(future_period, times)
      create_for_period(future_period, times, current_time)
    end
  end


  private


  # Clean notification times for future period.
  #
  # @param future_period [FutureCriticalPeriod]
  # @param notification_times [Array<Time>]
  def clean_for_period(future_period, notification_times)
    future_period.notifications.all.each do |existing_notification|
      unless notification_times.include?(existing_notification.time.utc)
        existing_notification.delete
      end
    end
  end


  # Create notification times for future period.
  #
  # @param future_period [FutureCriticalPeriod]
  # @param notification_times [Array<Time>]
  # @param border_time [Time] - time before which notifications should not be created.
  def create_for_period(future_period, notification_times, border_time)
    notification_times.each do |time|
      if border_time < time
        future_period.notifications.create!(time: time)
      end
    end
  end


  # Get notification times for future period.
  #
  # @param future_period [FutureCriticalPeriod]
  # @param time_zone [String] - time zone name.
  # @param notify_before [Array] - array of numbers which represents days before notifications.
  # @param notify_at [Fixnum] - number which represents hour of notification.
  #
  # @return [Array<Time>]
  def get_notification_times(future_period, time_zone, notify_before, notify_at)
    notification_times = []
    default_time = Time.find_zone(time_zone).local(future_period.from.year,
                                                  future_period.from.month,
                                                  future_period.from.day,
                                                  notify_at)
    notify_before.each do |days_before|
      time = default_time - days_before.days
      notification_times.push(time.utc)
    end

    notification_times
  end
end