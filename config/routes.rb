Youtubemymusic::Application.routes.draw do

  get "home/index"
  get "home/about", :as => "about"

  resources :playlists

  root :to => 'home#index'

end
