namespace :api, defaults: { format: :json } do

  namespace :client_admin do
    resource :charts, only: [:show]
    resource :reports, only: [:show]
  end

  namespace :v1 do
    resources :user_onboardings, only: [:update]
    resources :onboardings, only: [:create]
    resources :email_info_requests, only: [:create]
    resources :cheers, only: [:create]
  end
end
