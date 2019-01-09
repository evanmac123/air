get "users/index"

post "sms"           => "receive_sms#create"
get "activity"      => "acts#index"
get "join"          => "signup_requests#new"

# moved these to top level but don't want to break old links
get "ard/:public_slug" => "public_boards#show", :as => "public_board"
get "ard/:public_slug/activity" => "acts#index", :as => "public_activity"
get "ard/:public_slug/tiles" => "tiles#index", :as => "public_tiles"
get "ard/:public_slug/tile/:id" => "tiles#show", :as => "public_tile"

resources :tiles, :only => [:index, :show]
resources :tile, :only => [:show], as: "sharable_tile"

resource :session, :only => [:create, :destroy], :controller => 'sessions'

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

resources :case_studies, only: [:index]

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

get "sign_in", to: redirect('/'), as: "sign_in"
delete "sign_out" => "sessions#destroy", as: "sign_out"

#Marketing Pages
get "marketing_site_home" => 'pages#home', as: 'marketing_site_home'
get "/team" => 'pages#home', as: 'team'
get "/careers" => 'pages#home', as: 'careers'
get "/privacy_policy" => 'pages#home', as: 'privacy'
get "/terms" => 'pages#home', as: 'terms'

#Form Pages
get "/login" => 'pages#form', as: 'login'
get "/request_account" => 'pages#form', as: 'request_account'
get "/request_demo" => 'pages#demo1', as: 'demo'

#Example Pages
get "/pages/gallery" => 'pages#gallery', as: 'gallery'


resources :boards, only: [:new, :create, :update]
resources :copy_boards, only: [:create]

resource  :user_intros, only: [:update]

resource :current_board, only: [:update]

resources :demo_requests, only: [:create, :new]
post 'demo_requests/marketing' => 'demo_requests#marketing'
resources :signup_requests, only: [:create, :new]
resources :board_name_validations, only: :show

resources :suggested_tiles, only: [:new, :create]
resource :change_email, only: [:new, :create, :show, :update]

# See CancelAccountController for why this isn't rolled into AccountController
resources :cancel_account, :only => [:show, :destroy]

resource :account, :only => [:update] do
  resource :phone, only: [:update] do
    patch :validate
  end
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
