Rails.application.routes.draw do
  mount ActionCable.server, at: '/cable'

  get '/home/stories', to: 'stories#public_index'
  get '/stories/:id/test', to: 'stories#testBroadcast'
  get '/stories/genres', to: 'stories#getGenres'
  post '/stories/:id/append', to: 'stories#append'
  post '/stories/:id/invite', to: 'stories#newInvites'
  post '/view-story/:id', to: 'stories#view'

  post '/login', to: 'authentication#login'

  post '/submission-vote', to: 'submissions#vote'
  
  post '/users/:id/profile/', to: 'users#profile'
  post '/users/:id/friend', to: 'users#friend'
  post '/users/:id/unfriend', to: 'users#unfriend'
  post '/users/:id/follow', to: 'users#follow'
  post '/users/:id/unfollow', to: 'users#unfollow'
  post '/users/:id/send-message', to: 'users#send-message'
  post '/users/friend-search', to: 'users#friend_search'
  post '/messages', to: 'users#get_messages'
  

  post '/search', to: 'search#search'

  resources :submissions
  # resources :votes
  resources :stories
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
