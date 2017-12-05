module Api
  class UserBaseController < UserBaseController
    protect_from_forgery with: :null_session
  end
end
