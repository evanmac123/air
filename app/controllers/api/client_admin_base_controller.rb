class Api::ClientAdminBaseController < Api::ApiController
  def authorized?
    signed_in? && current_user.authorized_to?(:client_admin)
  end
end
