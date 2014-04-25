class ClientAdminBaseController < ApplicationController
  must_be_authorized_to :client_admin
  layout "client_admin_layout"

  protected

  def load_tags
    @tags = TileTag.alphabetical
  end

  def load_locations
    @locations = current_user.demo.locations.alphabetical
  end

  def param_path
    @param_path ||= params[:path].nil? ? :undefined : params[:path].to_sym
  end
end
