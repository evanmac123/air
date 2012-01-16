Health::Application.routes.draw do
  match "sms"        => "sms#create", :via => :post
  match "email"      => "email_command#create", :via => :post
  match "activity"   => "acts#index"
  match "scoreboard" => "scores#index"

  resource :session, :controller => 'sessions'

  resource  :conference_feed, :only => [:show]

  resource :phone,      :only => [:update]

  resources :invitations, :only => [:new, :create, :show]
  namespace :invitation do
    resource :resend
    resource :acceptance
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
      resources :users
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

      namespace :reports do
        resource :location_breakdown, :only => [:show]
      end
    end

    resources :users, :only => [] do
      resources :invitations, :only => [:create]
      resources :task_suggestions, :only => [:update], :shallow => true
    end

    resources :bad_words
  end
end
