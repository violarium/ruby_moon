Rails.application.routes.draw do

  # List of available locale values for route.
  # Default locale will be excluded - it means, that without prefix it will be default.
  locales = Rails.application.config.i18n.available_locales.reject do |locale|
    locale == Rails.application.config.i18n.default_locale
  end

  scope '(:locale)', locale: /#{locales.join('|')}/ do
    root 'home#show', as: 'home_page'
    get '/about' => 'pages#about', as: 'about_page'

    get '/sign_in' => 'sessions#new', as: 'sign_in'
    post '/sign_in' => 'sessions#create'
    delete '/sign_out' => 'sessions#destroy', as: 'sign_out'

    get '/sign_up' => 'profiles#new', as: 'sign_up'
    post '/sign_up' => 'profiles#create'

    get '/password-reset' => 'password_resets#new', as: 'send_password_reset'
    post '/password-reset' => 'password_resets#create'
    get '/password-reset/:token' => 'password_resets#edit', as: 'reset_password'
    put '/password-reset/:token' => 'password_resets#update'

    get '/profile' => 'profiles#edit', as: 'profile'
    put '/profile' => 'profiles#update'
    get '/profile/password' => 'profiles/passwords#edit', as: 'profile_password'
    put '/profile/password' => 'profiles/passwords#update'
    get '/profile/notifications' => 'profiles/notifications#edit', as: 'profile_notifications'
    put '/profile/notifications' => 'profiles/notifications#update'
    post '/profile/web-subscription/subscribe' => 'profiles/web_subscriptions#create', as: 'profile_web_subscribe'

    get '/calendar/(:year/:month)' => 'calendar#index', as: 'calendar'
    get '/calendar/day/:year/:month/:day' => 'calendar#edit', as: 'calendar_day'
    put '/calendar/day/:year/:month/:day' => 'calendar#update'
  end
end
