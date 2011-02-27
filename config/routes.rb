Health::Application.routes.draw do
  match "sms"      => "sms#create", :via => :post
  match "activity" => "acts#index"

  resources :phones,      :only => [:create]
  resources :invitations, :only => [:show]
  resources :acts,        :only => [:index, :create]
  resources :users,       :only => [:new, :index, :show] do
    resource :password,
      :controller => 'passwords',
      :only       => [:create, :edit, :update]

    resource :friendship, :only => [:create, :destroy]
  end

  # Override Clearance's sign_up and password routes
  resources :passwords,
    :controller => 'passwords',
    :only       => [:new, :create]

  match "sign_up"  => "users#new"

  root :to => 'homes#show'

  resource :home,  :only => :show
  resource :admin, :only => :show

  resources :pages

  namespace :account do
    resource :phone, :only => [:edit, :update]
  end

  namespace :admin do
    resources :demos, :only => [:new, :create, :show] do
      resources :users, :only => [:create]
    end
    resources :users, :only => [] do
      resources :invitations, :only => [:create]
    end
  end
end
