Health::Application.routes.draw do
  get "invitations/create"

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

  resources :players, :only => [] do
    resources :joins, :only => [:new, :create]
  end
end
