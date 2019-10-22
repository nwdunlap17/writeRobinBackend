Rails.application.routes.draw do
  mount ActionCable.server, at: '/cable'

  get '/home/stories', to: 'stories#public_index'
  get '/stories/:id/test', to: 'stories#testBroadcast'
  get '/stories/genres', to: 'stories#getGenres'
  post '/stories/:id/append', to: 'stories#append'
  post '/view-story/:id', to: 'stories#view'

  post '/login', to: 'authentication#login'

  post '/submission-vote', to: 'submissions#vote'
  
  post '/users/:id/profile/', to: 'users#profile'

  resources :submissions
  # resources :votes
  resources :stories
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
