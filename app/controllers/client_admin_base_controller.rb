class ClientAdminBaseController < ApplicationController
  must_be_authorized_to :client_admin,   unless: [:explore_token_allowed, :onboarding_auth]
  must_be_authorized_to :explore_family, if:     [:explore_token_allowed]

  layout "client_admin_layout"

  before_filter :set_is_client_admin_action

  protected

  def explore_token_allowed
    false
  end

  def onboarding_auth
    current_user.user_onboarding && onboarding_controllers
  end

  def onboarding_controllers
    params[:controller] == "client_admin/reports" || params[:controller] == "client_admin/board_stats_grid"
  end

  def load_tags
    @tags = TileTag.alphabetical
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
