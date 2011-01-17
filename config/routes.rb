Health::Application.routes.draw do
  match "sms"      => "sms#create", :via => :post
  match "activity" => "acts#index"

  resources :phones,      :only => [:create]
  resources :invitations, :only => [:show]
  resources :acts,        :only => [:index]
  resources :users,       :only => [:index, :show] do
    resource :friendship, :only => [:create, :destroy]
  end

  root :to => 'homes#show'

  resource :home,  :only => :show
  resource :admin, :only => :show

  namespace :admin do
    resources :demos, :only => [:new, :create, :show] do
      resources :users, :only => [:create]
    end
    resources :users, :only => [] do
      resources :invitations, :only => [:create]
    end
  end
end
