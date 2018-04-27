namespace :client_admin do
  resources :tile_previews, only: [:show]

  resource :reports, only: [:show]

  resources :users, only: [:index, :create, :edit, :update, :destroy] do
    resource :invitation, :only => :create
  end

  resource :tiles_digest_preview, only: [] do
    get 'sms', as: 'sms'
    get 'email', as: 'email'
  end

  resources :tile_user_notifications, only: [:create, :new]

  resources :locations, :only => :create

  resources :tiles do
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
      post 'duplicate'
    end
  end

  resources :tile_images, only: :index

  resource :tiles_digest_notification, only: :create do
    member do
      post 'save'
    end
  end

  resources :tiles_follow_up_email

  resource :share, only: :show do
    member do
      get 'show_first_active_tile'
    end
  end

  resource :tiles_report, only: :show

  resources :public_boards, only: [:create, :destroy]

  resource :billing_information

  resources :prizes, only: [:index, :create] do
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
