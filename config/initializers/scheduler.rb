require 'rufus-scheduler'

unless defined?(Rails::Console)
  scheduler = Rufus::Scheduler.singleton

  # Notifications about upcoming periods
  scheduler.every '1m' do
    Registry.instance[:notification_sender].notify_upcoming
  end
end
