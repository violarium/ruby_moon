namespace :periods do
  desc "Rebuild future periods for all the users"
  task :rebuild_future do
    predictor = PeriodPredictor.default_predictor
    User.all.each { |user| predictor.refresh_for(user) }
  end
end
