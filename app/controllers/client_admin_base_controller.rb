class ClientAdminBaseController < ApplicationController
  before_filter :set_is_client_admin_action

  layout "client_admin_layout"

  private

    def authenticate
      authenticate_user
    end

    def authorize
      return true if onboarding_auth
      return true if current_user.authorized_to?(:client_admin)

      redirect_to '/'
      return false
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
