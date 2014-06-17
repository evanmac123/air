class Admin::ResetBulkUploadsController < AdminBaseController
  def destroy
    demo = Demo.find(params[:id])
    demo.update_attributes(upload_in_progress: false)
    flash[:success] = "OK, the upload-in-progress status for this board is reset."
    redirect_to :back
  end
end
