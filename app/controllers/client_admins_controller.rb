class ClientAdminsController < ApplicationController
  must_be_authorized_to :client_admin

  def show
    render :text => "COMING SOON"
  end
end
