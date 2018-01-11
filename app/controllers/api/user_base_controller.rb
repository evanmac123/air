class Api::UserBaseController < Api::ApiController
  def authorized?
    signed_in?
  end
end
