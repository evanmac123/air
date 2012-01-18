module Clearance::Authentication
  module InstanceMethods
    def authenticate_with_cookie_renewal_and_session_open_flag
      authenticate_without_cookie_renewal_and_session_open_flag
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

    def sign_in_with_remember_me_and_session_open_flag(user, remember_me=false)
      sign_in_without_remember_me_and_session_open_flag(user)
      if self.current_user
        session[:session_open] = true
        session[:remember_me] = remember_me
      else
        session[:remember_me] = false
      end
    end

    alias_method_chain :authenticate, :cookie_renewal_and_session_open_flag
    alias_method_chain :sign_in, :remember_me_and_session_open_flag

    protected

    def remember_token_expiration
      if session[:remember_me]
        5.years.from_now
      else
        Clearance.configuration.cookie_expiration.call
      end
    end
  end
end
