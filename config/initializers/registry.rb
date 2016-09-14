require "#{Rails.root}/lib/registry"

registry = Registry.instance

registry.define_lazy :period_predictor do
  PeriodPredictor.new(NotificationBuilder.new, 28, 4, 3)
end

registry.define_lazy :notification_sender do
  NotificationSender.new
end
