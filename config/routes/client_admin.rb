resource :client_admin, :only => :show

namespace :client_admin do
  resource :segmentation


  resource :reports do
    post "/temporary_create", to: "reports#temporary_create"
  end

  resources :board_stats_grids, :only => [:index] do
    collection do
      get 'new_completions_count'
    end
  end

  resources :users, only: [:index, :create, :edit, :update, :destroy] do
    resource :invitation, :only => :create
  end
  resources :users_invites, only: :create
  get 'preview_tiles_digest_email', to: 'users_invites#preview_tiles_digest_email'

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
      get 'next_tile'
    end
  end

  resources :public_tiles, only: :update
  resources :sharable_tiles, only: :update
  resources :tile_images, only: :index

  resource :tiles_digest_notification, only: :create

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