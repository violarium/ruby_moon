require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyMoon
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # Look at config/initializers/i18n

    # Autoload lib folder
    config.autoload_paths << Rails.root.join('lib')

    # Mailer settings
    unless Rails.application.secrets.mail.nil?
      config.action_mailer.delivery_method = Rails.application.secrets.mail[:delivery_method]
      config.action_mailer.smtp_settings = Rails.application.secrets.mail[:smtp_settings]
      config.action_mailer.default_options = Rails.application.secrets.mail[:default_options]
      config.action_mailer.default_url_options = Rails.application.secrets.mail[:default_url_options]
    end
  end
end
