Rails.application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
Rails.application.config.i18n.available_locales = User::ALLOWED_LOCALES.keys
Rails.application.config.i18n.default_locale = User::ALLOWED_LOCALES.keys.first