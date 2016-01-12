class NotificationSender
  # Send notifications about upcoming critical periods.
  def notify_upcoming
    current_time = Time.now

    FutureCriticalPeriod.where(:'notifications.time'.lte => current_time).all.each do |period|
      PeriodsMailer.critical_period(period).deliver_now
      period.notifications.all.each do |notification|
        notification.delete if notification.time <= current_time
      end
    end
  end
end