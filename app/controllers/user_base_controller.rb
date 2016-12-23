class UserBaseController < ApplicationController
  def authorized?
    require_login
    return true if current_user.is_a?(User)
    return false
  end
end
