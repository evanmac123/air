module Api
  class ClientAdminBaseController < ClientAdminBaseController
    protect_from_forgery with: :null_session
  end
end
