get 'explore/campaigns/*campaign', to: 'explore#show'
resource :explore, only: [:show], controller: :explore

namespace :explore do
  resource  :search, only: [:show]
  resource  :copy_tile, only: [:create]
  resources :tile_previews, only: [:show], path: "tile"
#   resources :campaigns, only: [:show]
end
