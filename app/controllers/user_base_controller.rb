class UserBaseController < ApplicationController
  def authenticate
    authenticate_user
  end

  def authorized?
    return true if current_user.is_a?(User)
    return false
  end
end
