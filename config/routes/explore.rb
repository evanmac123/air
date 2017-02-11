resource :explore, only: [:show], controller: :explore

namespace :explore do
  constraints Clearance::Constraints::SignedIn.new { |user| user.is_site_admin } do
    resource  :search, only: [:show]
  end

  resources :organizations, only: [:show]
  resource  :copy_tile, only: [:create]
  resources :tile_previews, only: [:show], path: "tile"
  resources :campaigns, only: [:show]
  resources :channels, only: [:show]
  resources :tile_features, only: [:show]
end
