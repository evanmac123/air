class ClientAdminBaseController < UserBaseController
  prepend_before_filter :authenticate

  layout "client_admin_layout"

  def authenticate
    return true if current_user
    return true if authenticate_by_onboarding_auth_hash
  end

  def authorized?
    return true if current_user.authorized_to?(:client_admin)
    return true if authorize_onboarding
    return false
  end

  private

    def authenticate_by_onboarding_auth_hash
      return false unless cookies[:user_onboarding]
      user_onboarding = UserOnboarding.where(auth_hash: cookies[:user_onboarding]).first
      if user_onboarding && !user_onboarding.completed
        sign_in(user_onboarding.user)
        redirect_to user_onboarding_path(current_user.user_onboarding.id, return_onboarding: true)
        return true
      else
        return false
      end
    end

    def authorize_onboarding
      current_user.user_onboarding && onboarding_user_allowed?
    end

    def onboarding_user_allowed?
      return true if params[:controller] == 'client_admin/reports'
      return true if params[:controller] == 'client_admin/board_stats_grid'
    end

    def load_locations
      # TODO: deprecate
      @locations = current_user.demo.locations.alphabetical
    end
end
