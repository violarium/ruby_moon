Rails.application.routes.draw do

  scope '(:locale)', locale: /en|ru|he/ do
    root 'home#show', as: 'home_page'

    get '/sign_in' => 'sessions#new', as: 'sign_in'
    post '/sign_in' => 'sessions#create'
    delete '/sign_out' => 'sessions#destroy', as: 'sign_out'

    get '/sign_up' => 'profiles#new', as: 'sign_up'
    post '/sign_up' => 'profiles#create'

    get '/profile' => 'profiles#edit', as: 'profile'
    put '/profile' => 'profiles#update'
    get '/profile/password' => 'profiles/passwords#edit', as: 'profile_password'
    put '/profile/password' => 'profiles/passwords#update'
    get '/profile/notifications' => 'profiles/notifications#edit', as: 'profile_notifications'
    put '/profile/notifications' => 'profiles/notifications#update'

    get '/calendar/(:year/:month)' => 'calendar#index', as: 'calendar'
    get '/calendar/day/:year/:month/:day' => 'calendar#edit', as: 'calendar_day'
    put '/calendar/day/:year/:month/:day' => 'calendar#update'
  end
end
