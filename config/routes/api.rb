namespace :api, defaults: { format: :json } do
  resources :acts, only: [:index]
  resources :tile_completions, only: [:create]
  resources :board_memberships, only: [:update]

  resources :tiles, only: [] do
    resources :tile_link_trackings, only: [:create]
  end

  namespace :client_admin do
    resource :charts, only: [:show]
    resource :reports, only: [:show]
    resource :reports, only: [:show]
    resources :tile_email_reports, only: [:index]
    resources :tile_thumbnails, only: [:index]
    resources :campaigns, only: [:create, :update]
    resources :population_segments, only: [:create, :update, :destroy, :index]

    resources :demos, only: [] do
      resource :tiles_digest_automator, only: [:update, :destroy]
    end

    resources :tiles, only: [] do
      scope module: "tile" do
        resources :sorts, only: [:create]
      end
    end
  end

  namespace :v1 do
    resources :email_info_requests, only: [:create]
    resources :cheers, only: [:create]
    resources :campaigns, only: [:index, :show]
  end
end
