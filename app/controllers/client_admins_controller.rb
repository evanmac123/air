class ClientAdminsController < ApplicationController
  must_be_authorized_to :client_admin

  def show
  end
end
