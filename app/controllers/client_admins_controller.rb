class ClientAdminsController < ApplicationController
  must_be_authorized_to :client_admin
  layout "client_admin_layout"

  def show
  end
end
