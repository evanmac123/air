class ClientAdmin::BulkUploadsController < ClientAdminBaseController
  def show
    current_user.demo.update_attributes(upload_in_progress: true)
    BulkUploadNotifier.new(current_user, params[:bucket], params[:key]).notify_us_of_upload
    redirect_to client_admin_users_path
  end
end
