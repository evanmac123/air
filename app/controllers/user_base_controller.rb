class UserBaseController < ApplicationController
  def authorized?
    signed_in?
  end
end
