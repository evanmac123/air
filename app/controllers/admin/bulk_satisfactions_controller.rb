class Admin::BulkSatisfactionsController < AdminBaseController
  REPORT_RECIPIENT = "admins@hengage.com"

  def create
    schedule_bulk_completes
    flash[:success] = "Bulk updates scheduled. It may take a few minutes for all updates to complete. Report will go to #{REPORT_RECIPIENT}."
    redirect_to :back
  end

  protected

  def schedule_bulk_completes
    emails = params[:completion][:emails].split
    Tile.delay.bulk_complete(params[:demo_id], params[:tile_id], emails)
  end
end
