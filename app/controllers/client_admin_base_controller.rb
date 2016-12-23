class ClientAdminBaseController < UserBaseController
  before_filter :set_is_client_admin_action

  layout "client_admin_layout"

  def authenticate
    return true if authenticate_by_onboarding_auth_hash
    super
  end

  def authorized?
    super
    return true if onboarding_auth
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
        return true
      else
        return false
      end
    end

    def onboarding_auth
      current_user.user_onboarding && onboarding_controllers
    end

    def onboarding_controllers
      params[:controller] == "client_admin/reports" || params[:controller] == "client_admin/board_stats_grid"
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
