class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  def create
    tiles_digest_form = TilesDigestForm.new(current_user, params[:digest])

    case params[:digest_type]
    when "test_digest"
      tiles_digest_form.send_test_email_to_self
    when "test_follow_up"
      tiles_digest_form.send_test_follow_up_to_self
    else
      tiles_digest_form.schedule_digest_and_followup!
    end

    flash[:digest_sent_type] = params[:digest_type]
    flash[:digest_sent_flag] = true

    redirect_to :back
  end
end
