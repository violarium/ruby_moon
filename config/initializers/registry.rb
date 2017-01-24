require "#{Rails.root}/lib/registry"

registry = Registry.instance

registry.define_lazy :period_predictor do
  PeriodPredictor.new(NotificationBuilder.new, 28, 4, 3)
end

registry.define_lazy :notification_sender do
  NotificationSender.new [registry[:notification_sender_webpush], registry[:notification_sender_mail]]
end

registry.define_lazy :notification_sender_webpush do
  NotificationSender::WebpushSender.new(Rails.application.secrets.webpush)
end

registry.define_lazy :notification_sender_mail do
  NotificationSender::MailSender.new
end
