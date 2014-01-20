class Admin::BulkSatisfactionsController < AdminBaseController
  REPORT_RECIPIENT = "admins@airbo.com"

  def create
    if schedule_bulk_completes
      flash[:success] = "Bulk updates scheduled. It may take a few minutes for all updates to complete. Report will go to #{REPORT_RECIPIENT}."
    else
      add_failure "Please enter email addresses before clicking 'Manually Complete'"
    end
    redirect_to :back
  end

  protected

  def schedule_bulk_completes
    email_string = params[:completion][:emails] 
    return false if email_string.blank?
    emails = email_string.split
    Tile.delay.bulk_complete(params[:demo_id], params[:tile_id], emails)
    true
  end
end
