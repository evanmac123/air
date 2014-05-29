class ClientAdmin::BulkUploadsController < ClientAdminBaseController
  def new
    @uploader = BulkUserUploader.new
    @uploader.success_action_redirect = client_admin_bulk_upload_path
  end

  def show
    BulkUploadNotifier.new(current_user, params[:bucket], params[:key]).notify_us_of_upload
    render inline: 'ok'
  end
end
