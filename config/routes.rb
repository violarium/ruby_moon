Rails.application.routes.draw do

  scope '(:locale)', locale: /en|ru|he/ do
    root 'home#show', as: 'home_page'

    get '/sign_in' => 'user_sessions#new', as: 'sign_in'
    post '/sign_in' => 'user_sessions#create'
    delete '/sign_out' => 'user_sessions#destroy', as: 'sign_out'

    get '/sign_up' => 'users#new', as: 'sign_up'
    post '/sign_up' => 'users#create'

    get '/settings/profile' => 'user_settings#edit_profile', as: 'edit_profile_settings'
    put '/settings/profile' => 'user_settings#update_profile', as: 'update_profile_settings'
    get '/settings/password' => 'user_settings#edit_password', as: 'edit_password_settings'
    put '/settings/password' => 'user_settings#update_password', as: 'update_password_settings'

    get '/calendar/(:year/:month)' => 'calendar#index', as: 'calendar'
    get '/calendar/day/:year/:month/:day' => 'calendar#show', as: 'calendar_day'
    put '/calendar/day/:year/:month/:day' => 'calendar#update', as: 'update_calendar_day'
  end
end
