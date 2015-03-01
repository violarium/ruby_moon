Rails.application.routes.draw do
  root 'home#show', as: 'home_page'

  get '/sign_in' => 'user_sessions#new', as: 'sign_in'
  post '/sign_in' => 'user_sessions#create'
  delete '/sign_out' => 'user_sessions#destroy', as: 'sign_out'

  get '/calendar/(:year/:month)' => 'calendar#index', as: 'calendar_index'
  get '/calendar/day/:year/:month/:day' => 'calendar#show', as: 'calendar_day'
  put '/calendar/day/:year/:month/:day' => 'calendar#update', as: 'update_calendar_day'
end
