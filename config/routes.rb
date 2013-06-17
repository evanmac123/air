Health::Application.routes.draw do
  match "sms"        => "sms#create", :via => :post
  match "email"      => "email_command#create", :via => :post
  match "activity"   => "acts#index"
  match "scoreboard" => "scores#index"
  match "join"       => "invitations#new"
  match "next"       => "pages#show", :id => "june2013_landing"

  resources :tiles, :only => [:index, :show]

  resource :session, :controller => 'sessions'

  resource :phone,      :only => [:update] do
    resource :verification, :only => [:show, :update]
  end
  get "invitation" => "email_previews#invitation", :as => "invitation_preview"
 
  resource :unsubscribe, :only => [:new, :create, :show]
  resources :invitations, :only => [:new, :create, :show]
  namespace :invitation do
    resource :resend
    resource :acceptance
    get "autocompletion" => "autocompletions#index", :as => "autocompletion"
    post "invite_friend" => "friend_invitations#create", :as => "invite_friend"
  end

  resources :acts,        :only => [:index, :create]
  resources :users,       :only => [:new, :index, :show] do
    resource :password,
      :controller => 'passwords',
      :only       => [:create, :edit, :update]

    resource :friendship, :only => [:create, :update, :destroy] do
      get 'accept', :on => :member  # For "Accept" link in friendship-request email
    end

    resources :acts, :only => [:index], :controller => "users/acts"

  end

  post 'resend_phone_verification' => 'users/phone_verification#create', :as => 'resend_phone_verification'
  delete 'cancel_phone_verification' => 'users/phone_verification#destroy', :as => 'cancel_phone_verification'

  match 'chart' => 'client_admins#chart', :via => :post

  post "ping" => "users/pings#create"
  # Override some Clearance routes
  resources :passwords,
    :controller => 'passwords',
    :only       => [:new, :create]

  match "sign_in"  => "sessions#new"
  match "sign_up"  => "users#new"
  match "sign_out" => "sessions#destroy"

  root :to => 'pages#show', :id => 'marketing'
  get "faq" => "pages#faq", :as => "faq"
  get "faq_body" => "pages#faq_body", :as => "faq_toc"
  get "faq_toc" => "pages#faq_toc", :as => "faq_body"

  get "terms" => "pages#terms", :as => "terms"
  get "privacy" => "pages#privacy", :as => "privacy"

  put "tutorial" => "tutorials#update", :as => "tutorial"
  post "tutorial" => "tutorials#create", :as => "tutorial"
  
  resource :home,  :only => :show
  resource :admin, :only => :show
  resource :client_admin, :only => :show
  namespace :client_admin do
    resource :segmentation

    resources :users do
      resource :invitation, :only => :create
    end

    resources :locations, :only => :create

    resources :tiles do
      resource :image, :only => :update
    end

    resource :tiles_digest_notification, only: [:create, :update]
  end

  resources :pages, :only => :show

  resource :account, :only => [:update] do
    resource :phone, :only => [:update]
    resource :avatar, :only => [:update, :destroy]
    resource :sms_slug, :only => [:update]
    resource :name, :only => [:update]
    resource :settings, :only => [:edit, :update]
    resource :location, :only => [:update]
  end

  resources :email_info_requests, :only => [:create]

  resource :demographics, :only => [:update]

  resource :logged_in_user_password, :only => [:update]

  resources :games

  namespace :admin do
    get 'exception' => 'exceptions#show'
    get 'sleep_forever' => 'sleep_forever#show'

    resources :rules, :except => :show

    resources :rule_values, :only => [:destroy]

    resources :tags

    resources :labels
    
    put "user_transfers", :controller => "user_transfers", :action => :update, :as => "user_transfer"
    post "lost_user", :controller => "lost_users", :action => :create, :as => "lost_user"

    resources :demos, :only => [:new, :create, :show, :destroy, :edit, :update] do
      # TODO: move :edit and :update onto resources :users below
      resources :users do
        resource :characteristics, :only => :update, :controller => "user_characteristics"
      end

      resources :rules, :only => [:index, :new, :create]

      resources :goals

      resource :bulk_load, :only => [:new, :create]

      namespace :reports do
        resource :activities, :only => [:create]
      end

      resources :bad_words

      resources :tiles do
        collection { post :sort }
        resource :bulk_satisfaction, :only => [:create]
      end


      resources :locations
      resource :reports, :only => :show
      namespace :reports do
        resource :location_breakdown, :only => [:show]
        resource :points, :only => [:show]
        resource :interactions, :only => [:show, :keepalive]
        resource :friendships, :only => :show
      end

      resources :characteristics

      resource :segmentation
      resource :targeted_messages

      resource :raffles
      resource :gold_coin_reset
      resource :peer_invitations, :only => [:show]
    end #demo namespace

    resources :users, :only => [] do
      resources :invitations, :only => [:create]
      resources :tile_completions, :only => [:create]
    end

    delete "reset_tiles" => "tile_completions#destroy", :as => :reset_tiles

    resources :bad_words

    resources :characteristics
  end
end
