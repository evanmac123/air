class ExploreBaseController < ApplicationController

  layout "client_admin_layout"

  def authenticate
    return if authenticated?
    return if authenticate_by_explore_token
    login_as_guest(find_current_board) if guest_user_allowed?

    authenticate_user
  end

  def authorized?
    return true if current_user.authorized_to?(:explore_family)
    return false
  end

  def current_user
    super || current_user_by_explore_token
  end

  def current_user_by_explore_token
    @current_user_by_explore_token
  end

  private

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

    # TODO: remove after opening up explore
    def allow_guest_user
      @guest_user_allowed_in_action = true
    end

    def guest_user_allowed?
      @guest_user_allowed_in_action
    end
end
