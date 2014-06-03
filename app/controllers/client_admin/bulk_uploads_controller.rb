class ClientAdmin::BulkUploadsController < ClientAdminBaseController
  def show
    BulkUploadNotifier.new(current_user, params[:bucket], params[:key]).notify_us_of_upload
    render inline: 'ok'
  end
end
