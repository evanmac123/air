Health::Application.routes.draw do
  match "sms"        => "sms#create", :via => :post
  match "activity"   => "acts#index"
  match "scoreboard" => "scores#index"

  resource :session, :controller => 'sessions'

  resource  :conference_feed, :only => [:show]

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
  match "sign_out" => "clearance/sessions#destroy"

  root :to => 'pages#show', :id => 'marketing'

  resource :home,  :only => :show
  resource :admin, :only => :show

  resources :pages, :only => :show

  namespace :account do
    resource :phone, :only => [:edit, :update]
    resource :avatar, :only => [:edit, :update, :destroy]
  end

  resource :friends, :only => [:show]

  namespace :admin do
    resources :demos, :only => [:new, :create, :show] do
      # TODO: move :edit and :update onto resources :users below
      resources :users, :only => [:create, :edit, :update] 
      resource :bulk_load, :only => [:new, :create]
    end
    resources :users, :only => [] do
      resources :invitations, :only => [:create]
    end
    resources :bad_messages, :only => [:index, :update] do
      resources :replies, :only => [:new, :create], :controller => 'bad_message_replies'
    end
  end
end
