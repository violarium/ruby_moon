class NotificationSender
  # Create notification sender instance with list of notification sender methods
  #
  # @param methods [Array]
  #
  def initialize(methods)
    @methods = methods
  end


  # Send notifications about upcoming critical periods.
  def notify_upcoming
    current_time = Time.now

    FutureCriticalPeriod.where(:'notifications.time'.lte => current_time).all.each do |period|
      unless period.user.nil?
        @methods.each { |method| method.send_notification(period) }
      end

      period.notifications.all.each do |notification|
        notification.delete if notification.time <= current_time
      end
    end
  end
end