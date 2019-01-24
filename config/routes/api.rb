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
    resources :campaigns, only: [:create, :update, :index, :destroy]
    resources :population_segments, only: [:create, :update, :destroy, :index]
    get 'tiles/filter', to: 'tiles#filter'
    resources :tiles, only: [:index, :update, :show] do
      member do
        post 'copy_tile'
        delete 'destroy_tile'
      end
    end

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
    resources :initialize, only: [:index]
    resources :email_info_requests, only: [:create]
    resources :cheers, only: [:create]
    resources :campaigns, only: [:index, :show]
    resources :tiles, only: [:show]
    post 'tiles/:id/mark_as_viewed', to: 'tiles#ping_tile_view'
    resources :ribbon_tags, only: [:index, :create, :update, :destroy]
    resources :board_settings, only: [:index]
  end

  namespace :sms_service do
    resources :handling, only: [:create]
  end
end
