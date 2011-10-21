Health::Application.routes.draw do
  match "sms"        => "sms#create", :via => :post
  match "email"      => "email_command#create", :via => :post
  match "activity"   => "acts#index"
  match "scoreboard" => "scores#index"
  match "mr/:link_type"         => "michelin_redirector#show", :via => :get

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

    resources :acts, :only => [:index], :controller => "users/acts"
  end

  # Override Clearance's sign_up and password routes
  resources :passwords,
    :controller => 'passwords',
    :only       => [:new, :create]

  match "sign_up"  => "users#new"
  match "sign_out" => "clearance/sessions#destroy"

  root :to => 'pages#show', :id => 'new_marketing'

  resource :home,  :only => :show
  resource :admin, :only => :show

  resources :pages, :only => :show

  resource :account, :only => [:update] do
    resource :phone, :only => [:update]
    resource :avatar, :only => [:update, :destroy]
    resource :sms_slug, :only => [:update]
  end

  resource :friends, :only => [:show]
  resource :followers, :only => [:show, :update]

  resources :email_info_requests, :only => [:create]

  namespace :admin do
    resources :rules, :only => [:index, :new, :create, :edit, :update]

    resources :rule_values, :only => [:destroy]

    resources :forbidden_rules, :only => [:index, :create, :destroy]

    resources :demos, :only => [:new, :create, :show, :destroy, :edit, :update] do
      # TODO: move :edit and :update onto resources :users below
      resources :users, :only => [:edit, :update, :create, :destroy] 
      resources :rules, :only => [:index, :new, :create]

      resources :bonus_thresholds, :only => [:edit, :update, :destroy], :shallow => true
      resources :bonus_thresholds, :only => [:new, :create]
      
      resources :levels, :only => [:edit, :update, :destroy], :shallow => true
      resources :levels, :only => [:new, :create]

      namespace :rules do
        resource :bulk_load, :only => [:create]
      end

      resource :bulk_load, :only => [:new, :create]

      resource :blast_sms, :only => [:new, :create]

      resource :send_activity_dump, :only => [:create]
    end

    resources :users, :only => [] do
      resources :invitations, :only => [:create]
    end

    resources :bad_messages, :only => [:index, :update] do
      resources :replies, :only => [:new, :create], :controller => 'bad_message_replies'
    end
  end
end
