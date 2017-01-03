get "users/index"

match "sms"           => "sms#create", :via => :post
match "email"         => "email_command#create", :via => :post
match "activity"      => "acts#index"
match "activity/admin_return_guide_displayed" => "acts#admin_return_guide_displayed"
match "scoreboard"    => "scores#index"
match "join"          => "signup_requests#new"

# moved these to top level but don't want to break old links
match "ard/:public_slug" => "public_boards#show", :as => "public_board", :via => :get
match "ard/:public_slug/activity" => "acts#index", :as => "public_activity", :via => :get
match "ard/:public_slug/tiles" => "tiles#index", :as => "public_tiles", :via => :get
match "ard/:public_slug/tile/:id" => "tiles#show", :as => "public_tile", :via => :get


match "myairbo/:id" => "user_onboardings#show", as: "myairbo"
match "newairbo" => "onboardings#new"

resources :onboardings, only: [:create, :new]
resources :user_onboardings, only: [:show, :create] do
  resources :tiles, only: [:show]
end

get "myairbo/:id/activity" => "user_onboardings#activity", as: :onboarding_activity

resources :tiles, :only => [:index, :show]
resources :tile, :only => [:show], as: "sharable_tile"
resources :tile_completions, :only => [:create]

resource :session, :controller => 'sessions'

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
  resource :dependent_user_invitation, only: [:new, :create]
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

# Override some Clearance routes
resources :passwords,
  :controller => 'passwords',
  :only       => [:new, :create]

match "sign_in"  => "sessions#new"
match "sign_up"  => "users#new"
match "sign_out" => "sessions#destroy"

get "company" => 'pages#company', as: 'company'
get "case-studies" => 'pages#case-studies', as: 'case_studies'
get "demo_link" => "pages#demo_link", as: "demo_link"
get "terms" => "pages#terms", :as => "terms"
get "privacy" => "pages#privacy", :as => "privacy"

resources :pages, only: :show
resource :support, only: :show


resource :home,  :only => :show

resources :boards, only: [:new, :create, :update]
resources :copy_boards, only: [:create]

resource  :user_intros, only: [:update]

resource :board_setting, only: [:show]
resource :current_board, only: [:update]


resources :demo_requests, only: [:create, :new]
resources :signup_requests, only: [:create, :new]
resources :board_name_validations, only: :show
resources :board_memberships, only: :destroy
resources :mute_followups, only: :update
resources :mute_digests, only: :update

resources :suggested_tiles, only: [:new, :show, :create]
resource :change_email, only: [:new, :create, :show]



# See CancelAccountController for why this isn't rolled into AccountController
resources :cancel_account, :only => [:show, :destroy]

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
