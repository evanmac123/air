class ClientAdminBaseController < UserBaseController
  layout "client_admin_layout"

  def authorized?
    signed_in? && current_user.authorized_to?(:client_admin)
  end
end
