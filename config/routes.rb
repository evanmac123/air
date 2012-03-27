Health::Application.routes.draw do
  match "sms"        => "sms#create", :via => :post
  match "email"      => "email_command#create", :via => :post
  match "activity"   => "acts#index"
  match "scoreboard" => "scores#index"
  match "join"       => "invitations#new"

  resource :session, :controller => 'sessions'

  resource  :conference_feed, :only => [:show]

  resource :phone,      :only => [:update] do
    resource :interstitial_verification, :only => [:show, :update]
  end

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

    resource :friendship, :only => [:create, :destroy]

    resources :acts, :only => [:index], :controller => "users/acts"
  end

  # Override some Clearance routes
  resources :passwords,
    :controller => 'passwords',
    :only       => [:new, :create]

  match "sign_in"  => "sessions#new"
  match "sign_up"  => "users#new"
  match "sign_out" => "clearance/sessions#destroy"

  root :to => 'pages#show', :id => 'marketing'
  get "faq" => "pages#faq", :as => "faq"
  get "faq_body" => "pages#faq_body", :as => "faq_toc"
  get "faq_toc" => "pages#faq_toc", :as => "faq_body"

  get "terms" => "pages#terms", :as => "terms"
  get "privacy" => "pages#privacy", :as => "privacy"

  put "tutorial" => "tutorials#update", :as => "tutorial"
  
  resource :home,  :only => :show
  resource :admin, :only => :show

  resources :pages, :only => :show

  resource :account, :only => [:update] do
    resource :phone, :only => [:update]
    resource :avatar, :only => [:update, :destroy]
    resource :sms_slug, :only => [:update]
    resource :name, :only => [:update]
    resource :settings, :only => [:edit, :update]
    resource :location, :only => [:update]
  end

  resource :friends, :only => [:show]
  resource :followers, :only => [:show, :update]

  resources :email_info_requests, :only => [:create]

  resource :demographics, :only => [:update]

  namespace :admin do
    resources :rules, :only => [:index, :new, :create, :edit, :update]

    resources :rule_values, :only => [:destroy]

    resources :forbidden_rules, :only => [:index, :create, :destroy]

    resources :tags

    resources :labels

    resources :demos, :only => [:new, :create, :show, :destroy, :edit, :update] do
      # TODO: move :edit and :update onto resources :users below
      resources :users do
        resource :characteristics, :only => :update, :controller => "user_characteristics"
      end

      resources :rules, :only => [:index, :new, :create]

      resources :bonus_thresholds, :only => [:edit, :update, :destroy], :shallow => true
      resources :bonus_thresholds, :only => [:new, :create]

      resources :levels, :only => [:edit, :update, :destroy], :shallow => true
      resources :levels, :only => [:new, :create]

      resources :goals

      resource :bulk_load, :only => [:new, :create]

      resource :blast_sms, :only => [:new, :create]

      resource :send_activity_dump, :only => [:create]

      resources :bad_words

      resources :suggested_tasks do
        resource :bulk_satisfaction, :only => [:create]
      end

      resources :self_inviting_domains

      resources :locations
      resource :reports, :only => :show
      namespace :reports do
        resource :location_breakdown, :only => [:show]
        resource :points, :only => [:show]
        resource :levels, :only => [:show]
        resource :interactions, :only => [:show, :keepalive]
      end

      resources :characteristics
    end #demo namespace

    resources :users, :only => [] do
      resources :invitations, :only => [:create]
      resources :task_suggestions, :only => [:update], :shallow => true
    end

    resources :bad_words

    resources :characteristics
  end
end
