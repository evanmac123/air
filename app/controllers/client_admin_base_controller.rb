class ClientAdminBaseController < ApplicationController
  must_be_authorized_to :client_admin
  layout "client_admin_layout"

  protected

  def load_locations
    @locations = current_user.demo.locations.alphabetical
  end
end
