class ClientAdmin::TilesFollowUpEmailController < ClientAdminBaseController
  def destroy
    @follow_up_email = current_user.demo.follow_up_digest_emails.find params[:id]
    @follow_up_email.destroy
  end
end
