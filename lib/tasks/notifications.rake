namespace :notifications do
  desc "Send notifications about upcoming critical periods"
  task :notify_upcoming => :environment do
    NotificationSender.new.notify_upcoming
  end
end
