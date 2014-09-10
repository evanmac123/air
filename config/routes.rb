Health::Application.routes.draw do
  match "sms"           => "sms#create", :via => :post
  match "email"         => "email_command#create", :via => :post
  match "activity"      => "acts#index"
  match "activity/admin_return_guide_displayed" => "acts#admin_return_guide_displayed"
  match "scoreboard"    => "scores#index"
  match "join"          => "invitations#new"

  # moved these to top level but don't want to break old links  
  match "client_admin/explore"     => "explores#show"
  match "client_admin/explore_new" => "explores#show"
  match "ard/:public_slug" => "public_boards#show", :as => "public_board", :via => :get
  match "ard/:public_slug/activity" => "acts#index", :as => "public_activity", :via => :get
  match "ard/:public_slug/tiles" => "tiles#index", :as => "public_tiles", :via => :get
  match "ard/:public_slug/tile/:id" => "tiles#show", :as => "public_tile", :via => :get

  resources :tiles, :only => [:index, :show]
  resources :tile_completions, :only => [:create]

  resource :session, :controller => 'sessions'

  resource :phone,      :only => [:update] do
    resource :verification, :only => [:show, :update]
  end
  get "invitation" => "email_previews#invitation", :as => "invitation_preview"
 
  resource :unsubscribe, :only => [:new, :create, :show]
  resources :invitations, :only => [:new, :create, :show]
  namespace :invitation do
    resource :resend
    resource :acceptance do
      get "generate_password", on: :member
    end
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

  post "ping" => "users/pings#create"
  post "universal_ping" => "users/pings#create_universal_ping"
  # Override some Clearance routes
  resources :passwords,
    :controller => 'passwords',
    :only       => [:new, :create]

  match "sign_in"  => "sessions#new"
  match "sign_up"  => "users#new"
  match "sign_out" => "sessions#destroy"

  root :to => 'pages#show', :id => 'welcome'
  get "product" => 'pages#product', as: 'product'
  get "faq" => "pages#faq", :as => "faq"
  get "faq_body" => "pages#faq_body", :as => "faq_toc"
  get "faq_toc" => "pages#faq_toc", :as => "faq_body"

  get "terms" => "pages#terms", :as => "terms"
  get "privacy" => "pages#privacy", :as => "privacy"
  
  resource :home,  :only => :show
  resource :admin, :only => :show
  resource :client_admin, :only => :show

  resources :boards, only: [:new, :create, :update]

  resource :current_board, only: [:update]  
  resource :explore, only: [:show] do
    resources :tile_previews, only: [:show]
    resource :copy_tile, only: [:create]
    resource :tile_likes, :only => [:create, :destroy, :show]
    resource :random_tile, only: [:show]
    member do
      get 'tile_tag_show'
    end
  end

  resources :board_name_validations, only: :show
  resources :board_memberships, only: :destroy
  resources :mute_followups, only: :update
  resources :mute_digests, only: :update

  namespace :client_admin do
    resource :segmentation

    resources :users do
      resource :invitation, :only => :create
    end
    resources :users_invites, only: :create
    get 'preview_invite_email', to: 'users_invites#preview_invite_email'
    get 'validate_email', to: 'users#validate_email'
    
    resources :locations, :only => :create

    resources :tiles do
      resource :image, :only => [:update, :show]
      resources :tile_completions, :only => [:index]      
      collection do
        get 'active_tile_guide_displayed'
        get 'clicked_first_completion_got_it'
        get 'clicked_post_got_it'
        get 'activated_try_your_board'
        get 'clicked_try_your_board_got_it'
      end
    end
    
    get 'tiles/:tile_id/non_completions' => "tile_completions#non_completions"
        
    resource :tiles_digest_notification, only: :create

    resources :tiles_follow_up_email, only: :destroy

    resources :payments
    resources :balances

    resources :inactive_tiles, only: :index
    resources :draft_tiles, only: :index

    resource :share, only: :show do
      member do
        get 'show_first_active_tile'
        
        get 'added_valid_user'        
        get 'number_of_valid_users_added'        
        
        get 'successfully_added_users'
        get 'clicked_skip'
        get 'clicked_mail_to'
        get 'got_error'
        
        get 'changed_message'
        get 'clicked_add_more_users'
        get 'successfully_sent'
        
        get 'clicked_success_mail'
        get 'clicked_success_twitter'
        
        get 'selected_public_board'

        get 'clicked_share_mail'
        get 'clicked_share_twitter'        
        get 'clicked_add_users'
        
      end
    end

    resource :tiles_report, only: :show

    resources :public_boards, only: [:create, :destroy]
    resource :explore, only: :show do
      member do
        get 'tile_tag_show'
        get 'tile_preview'        
      end
    end
    
    resources :tile_tags, only: [:index] do
      collection do
        get 'add'
      end
    end

    resource :billing_information

    resources :prizes, only: :index do 
      collection do
        post 'save_draft'
        post 'start'
        post 'update'
        get 'cancel'
        get 'end_early'
        post 'pick_winners'
        delete 'delete_winner/:user_id' => 'prizes#delete_winner', as: :delete_winner
        get 'repick_winner/:user_id' => 'prizes#repick_winner', as: :repick_winner
        get 'start_new'
      end
    end

    resource :bulk_upload
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

  resources :thumbnails, :only => [:index]

  resources :guest_user_conversions, :only => [:create]
  resource :guest_user_reset, :only => [:update]

  # See CancelAccountController for why this isn't rolled into AccountController
  resources :cancel_account, :only => [:show, :destroy]

  namespace :admin do
    get 'exception' => 'exceptions#show'
    get 'sleep_forever' => 'sleep_forever#show'

    resources :rule_values, :only => [:destroy]

    resources :tags

    resources :labels
    
    post "lost_user", :controller => "lost_users", :action => :create, :as => "lost_user"

    resources :demos, :only => [:new, :create, :show, :edit, :update] do
      # TODO: move :edit and :update onto resources :users below
      resources :users, :only => [:index, :edit, :update, :destroy] do
        resource :characteristics, :only => :update, :controller => "user_characteristics"
        resource :test_status, :only => :update
      end

      resource :bulk_load, :only => [:new, :create]

      namespace :reports do
        resource :activities, :only => [:create]
      end

      resources :tiles do
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
      resource :paid_status
    end #demo namespace

    resources :users, :only => [] do
      resources :invitations, :only => [:create]
    end

    delete "reset_tiles" => "tile_completions#destroy", :as => :reset_tiles

    resources :characteristics

    resources :reset_bulk_uploads, only: [:destroy]
  end
end
