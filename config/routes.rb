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

  get "admin/organizations/metrics" => "admin/organizations#metrics", :as => "organization_metrics"
  post "admin/organizations/metrics" => "admin/organizations#metrics_recalc", :as => "organization_metrics"

  resources :tiles, :only => [:index, :show]
  resources :tile, :only => [:show], as: "sharable_tile"
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
  get "company" => 'pages#company', as: 'company'
  get "product" => 'pages#product', as: 'product'
  get "faq" => "pages#faq", :as => "faq" # FIXME dead url?
  get "faq_body" => "pages#faq_body", :as => "faq_toc" # FIXME dead url?
  get "faq_toc" => "pages#faq_toc", :as => "faq_body" # FIXME dead url?

  get "terms" => "pages#terms", :as => "terms"
  get "privacy" => "pages#privacy", :as => "privacy"

  resources :pages, :only => :show
  resource :support, only: :show

  resource :home,  :only => :show
  resource :admin, :only => :show
  resource :client_admin, :only => :show

  resources :boards, only: [:new, :create, :update]
  resources :copy_boards, only: [:create]
  resources :parent_boards, only: [:show]

	resource :board_setting, only: [:show]
  resource :current_board, only: [:update]
  resource :explore, only: [:show] do
    resources :tile_previews, only: [:show], :path => "tile"
    resource :copy_tile, only: [:create]
    resource :tile_likes, :only => [:create, :destroy, :show]
    resource :random_tile, only: [:show]
    member do
      get 'tile_tag_show'
    end
    resources :topics, only: [:show]
  end



  resources :demo_requests, only: :create
  resources :board_name_validations, only: :show
  resources :board_memberships, only: :destroy
  resources :mute_followups, only: :update
  resources :mute_digests, only: :update
  resource  :intro_viewed_status, only: :update

  resources :locations, only: :index

  resources :suggested_tiles, only: [:new, :show, :create]

  namespace :client_admin do
    resource :segmentation

    resources :users, only: [:index, :create, :edit, :update, :destroy] do
      resource :invitation, :only => :create
    end
    resources :users_invites, only: :create
    get 'preview_invite_email', to: 'users_invites#preview_invite_email'

    resources :locations, :only => :create

    resources :multiple_choice_tiles, controller: 'tiles'

    resources :tiles do
      collection do
        get "blank"
      end

      resource :image, :only => [:update, :show]
      resources :tile_stats, :only => [:index]
      resources :tile_stats_charts, :only => [:create]
      resources :tile_stats_grids, :only => [:index] do
        collection do
          get 'new_completions_count'
        end
      end
      member do
        post 'sort'
        put  'status_change' #FIXME this is a temporary hack to avoid having to rewrite all of the existing code related to tile status update.
        put  'update_explore_settings' #FIXME this is a temporary hack to avoid having to rewrite all of the existing code related to tile explore settings update.
        post 'duplicate'
      end
    end

    resources :public_tiles, only: :update
    resources :sharable_tiles, only: :update
    resources :tile_images, only: :index

    resource :tiles_digest_notification, only: :create

    resources :tiles_follow_up_email, only: :destroy

    resources :inactive_tiles, only: :index do
      member do
        post 'sort'
      end
    end

    resource :share, only: :show do
      member do
        get 'show_first_active_tile'
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

    resources :board_settings, only: :index do
      collection do
        put 'name'
        put 'logo'
        put 'email'
        put 'email_name'
        put 'public_link'
        put 'welcome_message'
				put 'weekly_activity_email'
        put 'cover_message'
        put 'cover_image'
      end
    end

    resource  :suggestions_access, only: [:update], controller: 'suggestions_access'
    resources :suggestions_access, only: [:index]
    resources :allowed_to_suggest_users, only: [:destroy, :show]
  end

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
  resources :submitted_tile_notifications, only: [:index]

  resources :potential_user_conversions, :only => [:create]
  resources :guest_user_conversions, :only => [:create]
  resource :guest_user_reset, :only => [:update] do
    member do
      post 'saw_modal'
    end
  end

  # See CancelAccountController for why this isn't rolled into AccountController
  resources :cancel_account, :only => [:show, :destroy]

  namespace :admin do

    resources :organizations do
      resources :contracts, controller: "contracts"
      resources :billings
    end

    resources :contracts do
      resources :upgrades, controller: "contracts"
      resources :billings
    end

    resources :billings

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

    resource :explore_digest, only: [:new, :create]
    resources :tile_images, only: [:create, :index, :destroy]
    resource :bulk_upload_progress, only: [:show]
    resource :bulk_upload_errors, only: [:show]
    resource :support, only: [:show, :edit, :update]
  end
end
