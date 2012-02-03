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
      cookies[:remember_me] = false
      sign_in_without_remember_me_and_session_open_flag(user)
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
    
    def sign_in_with_increment_sign_ins(user, remember_me=false)
      sign_in_without_increment_sign_ins(user, remember_me=false)
      current_user.session_count += 1
      current_user.save
      session.delete(:invite_friends_modal_shown)
    end

    alias_method_chain :authenticate, :cookie_renewal_and_session_open_flag
    alias_method_chain :sign_in, :remember_me_and_session_open_flag
    #alias_method_chain :sign_in, :increment_sign_ins

    protected

    def remember_token_expiration
      unless cookies[:remember_me].empty?
        10.years.from_now
      else
        Clearance.configuration.cookie_expiration.call
      end
    end
  end
end
