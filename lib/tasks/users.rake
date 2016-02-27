namespace :users do
  desc "Clear expired tokens"
  task :delete_expired_tokens => :environment do
    UserToken.delete_expired
  end
end
