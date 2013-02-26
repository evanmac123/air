class ClientAdmin::SimpleBulkUploadsController < ApplicationController
  must_be_authorized_to :site_admin

  def show
    @uploader = BulkLoaderUploader.new
    @uploader.success_action_redirect = client_admin_simple_bulk_upload_acceptance_path
  end
end
