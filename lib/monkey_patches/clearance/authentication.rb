module Clearance::Authentication
  module InstanceMethods
    module AuthenticateWithCookieRenewalAndSessionOpenFlag
      def authorize
        super
        if signed_in?
          cookies[:remember_token] = {
            :value   => cookies[:remember_token],
            :expires => remember_token_expiration
          }
        elsif session[:session_open]
          session[:session_open] = false
          flash[:failure] = "Your session has expired. Please log back in to continue."
        end 
      end
    end

    module SignInWithRememberMeAndSessionOpenFlag
      def sign_in(user, remember_me=false)
        cookies[:remember_me] = false
        super(user)
        if self.current_user
          session[:session_open] = true
          cookies[:remember_me] = {:value => remember_me, :expires => 10.years.from_now}
        else
          cookies[:remember_me] = false
        end
        current_user.session_count += 1
        current_user.save
        session.delete(:invite_friends_modal_shown)
      end
    end
    
    include SignInWithRememberMeAndSessionOpenFlag
    include AuthenticateWithCookieRenewalAndSessionOpenFlag

    protected

    def remember_token_expiration
      unless cookies[:remember_me].blank?
        10.years.from_now
      else
        Clearance.configuration.cookie_expiration.call
      end
    end
  end
end
