class NotificationSender::MailSender
  def send_notification(period)
    PeriodsMailer.critical_period(period).deliver_now
  end
end
