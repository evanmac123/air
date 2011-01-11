class AdminBaseController < ApplicationController
  before_filter :authenticate

  protected

  def authenticate
    return true if Rails.env.test?

    authenticate_or_request_with_http_basic do |username, password|
      username == "demo" && password == "salud"
    end
  end
end
