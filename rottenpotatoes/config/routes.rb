Rottenpotatoes::Application.routes.draw do
  root :to => redirect('/movies')
  get 'pages/home'

  devise_for :users, controllers:{
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  resources :movies
  # map '/' to be a redirect to '/movies'

  # root 'pages#home'
  # devise_for :users, controllers: {
  #   omniauth_callbacks: 'users/omniauth_callbacks',
  #   sessions: 'users/sessions',
  #   registrations: 'users/registrations'
  # }
  
  post '/movies/search_tmdb' => 'movies#search_tmdb', :as => 'search_tmdb'
end
