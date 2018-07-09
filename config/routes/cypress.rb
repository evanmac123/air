namespace :cypress do
  resources :test_database, only: [:index, :show, :create, :destroy]
end
