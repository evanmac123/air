resource :admin, :only => :show

namespace :admin do
  constraints Clearance::Constraints::SignedIn.new { |user| user.is_site_admin } do
    mount Searchjoy::Engine, at: "searchjoy"
  end

  namespace :chart_mogul do
    resources :organizations, only: [:destroy] do
      post 'sync'
    end
  end

  resources :user_migrators
  resources :campaigns
  resources :case_studies, except: :show

  resources :organization_registrations, only: [:new, :create]

  resources :organizations, as: :customers
  resources :organizations do
    resources :subscriptions, only: [:create, :destroy] do
      patch 'cancel'
      resources :invoices, only: [:create, :destroy]
    end
  end

  namespace :reference do
    get "styleguide"
  end

  resources :rule_values, :only => [:destroy]

  resources :labels

  post "lost_user", :controller => "lost_users", :action => :create, :as => "lost_user"

  resources :unmatched_boards, only: [:index, :update] do
    collection  do
      post :update
    end
   end

  resources :demos do
    resources :users do
      resource :characteristics, :only => :update, :controller => "user_characteristics"
      resource :test_status, :only => :update
    end

    resource :bulk_user_deletions
    resource :dependent_board, only: [:show] do
      get "users", to: "dependent_boards/users#index"
    end

    post "dependent_board/send_targeted_message", to: "dependent_boards#send_targeted_message"

    resource :bulk_load, :only => [:new, :create]

    namespace :reports do
      resource :activities, :only => [:create]
    end

    resources :locations

    resources :characteristics

    resource :segmentation

    resource :targeted_messages

    resource :raffles
    resource :gold_coin_reset
    resource :peer_invitations, :only => [:show]
  end #demo namespace

  resources :users, :only => [] do
    resources :invitations, :only => [:create]
  end

  delete "reset_tiles" => "tile_completions#destroy", :as => :reset_tiles

  resources :characteristics

  resources :reset_bulk_uploads, only: [:destroy]

  resources :explore_digests do
    post :deliver
  end
  resources :tile_images, only: [:create, :index, :destroy]
  resource :bulk_upload_progress, only: [:show]
  resource :bulk_upload_errors, only: [:show]
end
