namespace :notifications do
  desc "Send notifications about upcoming critical periods"
  task :notify_upcoming => :environment do
    Registry.instance[:notification_sender].notify_upcoming
  end
end
