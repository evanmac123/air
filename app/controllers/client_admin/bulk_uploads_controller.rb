class ClientAdmin::BulkUploadsController < ApplicationController
  must_be_authorized_to :site_admin

  layout 'client_admin_layout'

  def show
    @uploader = BulkLoaderUploader.new
    @uploader.success_action_redirect = "/"
  end

  def create
    redirect_to client_admin_bulk_upload_preview_path
  end
end
