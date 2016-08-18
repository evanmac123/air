class ClientAdmin::TilesFollowUpEmailController < ClientAdminBaseController

  def update

  end

  def destroy
    @follow_up_email = current_user.demo.follow_up_digest_emails.find params[:id]
    @follow_up_email.destroy
    schedule_followup_cancelled_ping
  end

  protected

  def schedule_followup_cancelled_ping
    ping 'Followup - Cancelled', {}, current_user
  end
end
