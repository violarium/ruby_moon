class NotificationSender
  # Send notifications about upcoming critical periods.
  def notify_upcoming
    current_time = Time.now

    FutureCriticalPeriod.where(:'notifications.time'.lte => current_time).all.each do |period|
      unless period.user.nil?
        PeriodsMailer.critical_period(period).deliver_now
      end

      period.notifications.all.each do |notification|
        notification.delete if notification.time <= current_time
      end
    end
  end
end