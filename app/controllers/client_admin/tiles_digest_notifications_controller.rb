class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  def create
    tiles_digest_form = TilesDigestForm.new(current_user, params[:digest])
    tiles_digest_form.schedule_digest_and_followup!

    flash[:digest_sent_flag] = true

    redirect_to :back
  end
end
