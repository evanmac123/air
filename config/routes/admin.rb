resource :admin, :only => :show

namespace :admin do
  constraints Clearance::Constraints::SignedIn.new { |user| user.is_site_admin } do
    mount Searchjoy::Engine, at: "searchjoy"
  end
  resources :user_migrators
  resource  :sales, only: [:show]
  resources :channels
  resources :campaigns
  resources :case_studies, except: :show
  resources :tiles_digests, only: [:index]

  resources :tile_features, only: [:index, :create, :update, :destroy, :new]

  resources :historical_metrics, only: [:create]
  namespace :sales do
    resources :organizations, only: [:new, :create]
    resources :leads, only: [:index]
    resources :lead_contacts, only: [:index, :edit, :update, :create, :destroy] do
      resources :invites, only: [:new]
      resources :tiles, only: [:index]
    end
  end

  resources :topics

  resource :client_kpi_report
  resource :financials_kpi_dashboard, only:[:show], controller: "financials/kpi_dashboard"

  resources :metrics
  resources :topic_boards
  resources :organizations, as: :customers
  resources :organizations do
    collection do
      post "import"
    end
    resources :contracts, controller: "contracts"
    resources :billings
  end

  resources :contracts do
    post "import", as: "import_contracts"
    get "import", on: :collection


    resources :upgrades, controller: "contracts"
    resources :billings
  end

  namespace :reference do
    get "styleguide"
  end

  resources :billings

  resources :rule_values, :only => [:destroy]

  resources :tags

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

  resources :explore_digests do
    post :deliver
  end
  resources :tile_images, only: [:create, :index, :destroy]
  resource :bulk_upload_progress, only: [:show]
  resource :bulk_upload_errors, only: [:show]
  resource :support, only: [:show, :edit, :update]
end
