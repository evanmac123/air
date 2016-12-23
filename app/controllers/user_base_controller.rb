class UserBaseController < ApplicationController
  def authorize!
    return false if require_login

    unless authorized?
      flash[:failure] = "Sorry, you don't have permission to access that part of the site."
      redirect_to root_path
      return false
    end

    return true
  end
end
