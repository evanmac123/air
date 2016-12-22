class UserBaseController < ApplicationController
  def authenticate
    authenticate_user
  end

  def authorized?
    return true if current_user.is_a?ç(User)
    return false
  end
end
