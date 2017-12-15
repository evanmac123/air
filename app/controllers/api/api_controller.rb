class Api::ApiController < ActionController::Base
  protect_from_forgery with: :null_session
  before_filter :authorize!

  def authorize!
    unless authorized?
      deny_access(authorization_flash)
    end
  end

  def authorized?
    return true
  end
end
