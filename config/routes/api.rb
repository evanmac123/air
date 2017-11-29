namespace :api, defaults: { format: :json } do
  resources :acts, only: [:index]

  resources :tiles, only: [] do
    resources :tile_link_trackings, only: [:create]
  end

  namespace :client_admin do
    resource :charts, only: [:show]
    resource :reports, only: [:show]
    resource :reports, only: [:show]
    resources :tile_email_reports, only: [:index]

    resources :demos, only: [] do
      resource :tiles_digest_automator, only: [:update, :destroy]
    end
  end

  namespace :v1 do
    resources :email_info_requests, only: [:create]
    resources :cheers, only: [:create]
  end
end
