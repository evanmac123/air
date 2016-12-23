module Clearance::Authentication
  module InstanceMethods
    module SignInWithRememberMe
      def sign_in(user, remember_me=false)
        cookies[:remember_me] = { value: remember_me, expires: 1.year.from_now }
        session.delete(:guest_user)
        super(user)
      end
    end
    include SignInWithRememberMe
  end
end

module Clearance::Authorization
  module InstanceMethods
    module YouveBeenSignedOutMessage
      def require_login
        unless signed_in?
          deny_access(%!You've been logged out due to inactivity. If needed, #{ActionController::Base.helpers.link_to "create or reset your password", '/passwords/new'}.!.html_safe)
        end
      end
    end
    include YouveBeenSignedOutMessage
  end
end
