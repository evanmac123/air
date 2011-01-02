Health::Application.routes.draw do
  match "sms" => "sms#create", :via => :post

  resources :phones,      :only => [:create]
  resources :invitations, :only => [:show]

  root :to => 'high_voltage/pages#show', :id => 'wireframes'

  resource :admin, :only => :show

  namespace :admin do
    resources :demos, :only => [:new, :create, :show] do
      resources :players, :only => [:create]
    end
    resources :players, :only => [] do
      resources :invitations, :only => [:create]
    end
  end
end
