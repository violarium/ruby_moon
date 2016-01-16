require 'rufus-scheduler'

unless defined?(Rails::Console)
  scheduler = Rufus::Scheduler.singleton

  # Notifications about upcoming periods
  scheduler.every '1m' do
    NotificationSender.new.notify_upcoming
  end
end
