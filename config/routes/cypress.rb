namespace :cypress do
  get 'test_database/csrf_token', to: 'test_database#csrf_token'
  resources :test_database, only: [:index, :show, :create, :destroy]
end
