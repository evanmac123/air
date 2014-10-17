# Notice of Security Vulnerability
# When a user's session expires, all a hacker has to do is rewind the clock 
# on that computer a bit and go to hengage.com (not hengage.com/sign_in) and 
# they will still be logged in. We may want to fix this at some point

module Clearance
  SESSION_EXPIRED = %!You've been logged out due to inactivity. If needed, <a href="/passwords/new">create or reset your password</a>.!.freeze
end

module Clearance::Authentication
  module InstanceMethods

    module SignInWithRememberMe
      def sign_in(user, remember_me=false)
        cookies[:remember_me] = {value: remember_me, expires: 1.year.from_now}
        super(user)
        if signed_in?
          # This bit is so that we can trigger the message in 
          # YouveBeenSignedOutMessage later
          session[:session_open] = true
        end

        # This is where we increment the session count so we can trigger things like the 
        # invite friends modal and the tutorial
        current_user.session_count += 1
        current_user.save

        session.delete(:guest_user)
      end
    end

    module YouveBeenSignedOutMessage
      def authorize
        super
        unless signed_in?
          # Clearance doesn't normally log you out, but we've added that feature.
          # So this gives a nice message if you're not authenticated but you 
          # were, say just a minute ago
          if session[:session_open]
            session[:session_open] = false
            flash[:failure] = Clearance::SESSION_EXPIRED
            flash[:failure_allow_raw] = true
          end

          # It doesn't make sense to carry over saved flashes from one session 
          # to the next, we we'll delete them here
        end 
      end
    end

    include YouveBeenSignedOutMessage 
    include SignInWithRememberMe
  end
end




module Clearance
  class Session
    def add_cookie_to_headers(headers)
      if cookies && cookies['remember_me'] == 1.to_s
        expire_time = 10.years.from_now.utc
      else
        expire_time = Clearance.configuration.cookie_expiration.call
      end
      
      if signed_in?
        Rack::Utils.set_cookie_header!(headers,
                                       REMEMBER_TOKEN_COOKIE,
                                       value:   current_user.remember_token,
                                       expires: expire_time,
                                       path:    "/",
                                       secure:  Rails.env.production?,
                                       httponly: true)
      end
    end

  end
end
