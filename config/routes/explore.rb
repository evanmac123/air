resource :explore, only: [:show], controller: :explore do
end

namespace :explore do
  resources :organizations, only: [:show]
  resource  :copy_tile, only: [:create]
  resources :tile_previews, only: [:show], path: "tile"
  resources :campaigns, only: [:show]
  resources :channels, only: [:show]
  resources :tile_features, only: [:show]
end
