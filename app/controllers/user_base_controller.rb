class UserBaseController < ApplicationController
  prepend_before_filter :require_login

  def authenticate
    refresh_activity_session(current_user)
  end

  def authorized?
    return true if current_user.is_a?(User)
    return false
  end
end
