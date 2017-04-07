namespace :api, defaults: { format: :json } do
  resource :charts, only: [:show]

  namespace :v1 do
    resources :user_onboardings, only: [:update]
    resources :onboardings, only: [:create]
    resources :email_info_requests, only: [:create]
    resources :cheers, only: [:create]
  end
end
