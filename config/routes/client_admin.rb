namespace :client_admin do
  resource :segmentation
  resources :tile_previews, only: [:show]

  resource :reports, only: [:show]

  resources :users, only: [:index, :create, :edit, :update, :destroy] do
    resource :invitation, :only => :create
  end
  resources :users_invites, only: :create
  get 'preview_tiles_digest_email', to: 'users_invites#preview_tiles_digest_email'

  resource :tiles_digest_preview, only: [] do
    get 'sms', as: 'sms'
  end

  resources :tile_user_notifications, only: [:create, :new]

  resources :locations, :only => :create

  resources :tiles do
    collection do
      get "blank"
    end

    get 'download_tile_report', to: 'tile_stats#download_report', as: 'download_report'

    resource :image, :only => [:update, :show]
    resources :tile_stats, only: [:index] do
    end
    resources :tile_stats_grids, :only => [:index] do
      collection do
        get 'new_completions_count'
      end
    end
    member do
      post 'sort'
      patch  'status_change' #FIXME this is a temporary hack to avoid having to rewrite all of the existing code related to tile status update.
      patch  'update_explore_settings' #FIXME this is a temporary hack to avoid having to rewrite all of the existing code related to tile explore settings update.
      post 'duplicate'
      get 'next_tile'
    end
  end

  resources :public_tiles, only: :update
  resources :tile_images, only: :index

  resource :tiles_digest_notification, only: :create do
    member do
      post 'save'
    end
  end

  resources :tiles_follow_up_email

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

  resource :billing_information

  resources :prizes, only: [:index, :update] do
    collection do
      post 'save_draft'
      post 'start'
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
      patch 'name'
      patch 'logo'
      patch 'email'
      patch 'email_name'
      patch 'public_link'
      patch 'welcome_message'
      patch 'weekly_activity_email'
      patch 'cover_message'
      patch 'cover_image'
      patch 'timezone'
      patch 'allow_unsubscribes'
    end
  end

  resource  :suggestions_access, only: [:update], controller: 'suggestions_access'
  resources :suggestions_access, only: [:index]
  resources :allowed_to_suggest_users, only: [:destroy, :show]
end
