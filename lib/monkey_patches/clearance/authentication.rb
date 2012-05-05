module Clearance::Authentication
  module InstanceMethods
    module AuthenticateWithCookieRenewalAndSessionOpenFlag
      def authorize
        super
        if signed_in?
          # setting this cookie here has no effect. Clearance will just overwrite it. 
          # That's why we have overwritten Clearance's add_cookie_to_headers method (below)
          #  -- Jack Desert May 7, 2012
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




module Clearance
  class Session
    def add_cookie_to_headers(headers)
      if cookies && cookies[:remember_me].present?
        expire_time = 10.years.from_now.utc
      else
        expire_time = Clearance.configuration.cookie_expiration.call
      end
      
      if signed_in?
        Rack::Utils.set_cookie_header!(headers,
                                       REMEMBER_TOKEN_COOKIE,
                                       :value => current_user.remember_token,
                                       :expires => expire_time,
                                       :path => "/")
      end
    end

  end
end
