Health::Application.routes.draw do
  root :to => 'high_voltage/pages#show', :id => 'wireframes'

  resource :admin, :only => :show

  namespace :admin do
    resources :demos, :only => [:new, :create, :show] do
      resources :players, :only => [:create]
    end
  end
end
