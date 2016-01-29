namespace :periods do
  desc "Rebuild future periods for all the users"
  task :rebuild_future => :environment do
    predictor = Registry.instance[:period_predictor]
    User.all.each { |user| predictor.refresh_for(user) }
  end
end
