get 'explore/campaigns/*campaign', to: 'explore#show'
get 'explore/not_found', to: 'explore#path_not_found'
resource :explore, only: [:show], controller: :explore

namespace :explore do
  resource  :search, only: [:show]
  resource  :copy_tile, only: [:create]
  resources :tile_previews, only: [:show], path: "tile"
end
