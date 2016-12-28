class ExploreBaseController < ApplicationController
  include AllowGuestUsers

  prepend_before_filter :authenticate

  layout "client_admin_layout"

  def authenticate
    return true if authenticate_by_explore_token
  end

  def authorize!
    unless authorized?
      require_login
    end
  end

  def authorized?
    return true if current_user.authorized_to?(:explore_family)
    return guest_user if guest_user_allowed?
    return false
  end

  def current_user
    super || current_user_by_explore_token || guest_user?
  end

  def current_user_by_explore_token
    @current_user_by_explore_token
  end

  private

    def guest_user?
      guest_user if guest_user_allowed?
    end

    def authenticate_by_explore_token
      explore_token = find_explore_token
      user = User.find_by_explore_token(explore_token)

      return false unless user.present? && user.is_client_admin_in_any_board

      remember_explore_token(explore_token)

      refresh_activity_session(user)
      remember_explore_user(UserRestrictedToExplorePages.new(user))
      return true
    end

    def find_explore_token
      params[:explore_token] || session[:explore_token]
    end

    def remember_explore_token(explore_token)
      session[:explore_token] = explore_token
    end

    def remember_explore_user(user)
      @current_user_by_explore_token = user
    end

    def guest_user_allowed?
      return true if params[:controller] == 'explore/tile_previews' && params[:action].in?(%w(show))
      return false
    end

    def find_board_for_guest
      Demo.new
    end
end
