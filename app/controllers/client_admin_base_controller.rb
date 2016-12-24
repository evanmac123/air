class ClientAdminBaseController < UserBaseController
  before_filter :set_is_client_admin_action

  layout "client_admin_layout"

  def authenticate
    return true if authenticate_by_onboarding_auth_hash
  end

  def authorized?
    return true if authorize_onboarding
    return true if current_user.authorized_to?(:client_admin)
    return false
  end

  private

    def authenticate_by_onboarding_auth_hash
      return false unless cookies[:user_onboarding]
      user_onboarding = UserOnboarding.where(auth_hash: cookies[:user_onboarding]).first
      if user_onboarding && !user_onboarding.completed
        sign_in(user_onboarding.user)
        refresh_activity_session(current_user)
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
      @locations = current_user.demo.locations.alphabetical
    end

    def param_path
      @param_path ||= params[:path].nil? ? :undefined : params[:path]
    end

    def set_is_client_admin_action
      @is_client_admin_action = true
    end
end
