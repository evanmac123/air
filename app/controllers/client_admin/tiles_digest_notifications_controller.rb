class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  def create
    @tiles_digest_form = TilesDigestForm.new(current_user, params[:digest])

    if params[:digest_type] == "test_digest"
      save_digest_form_params
      @tiles_digest_form.submit_send_test_digest
    else
      session[:digest] = nil
      @tiles_digest_form.submit_schedule_digest_and_followup
    end

    flash[:digest_sent_type] = digest_sent_type
    flash[:digest_sent_flag] = true

    redirect_to :back
  end

  protected

  def save_digest_form_params
    session[:digest] = params[:digest]
  end

  def digest_sent_type
    if params[:digest_type] == "test_digest"
      if @tiles_digest_form.with_follow_up?
        "test_digest_and_follow_up"
      else
        "test_digest"
      end
    else
      "digest_and_follow_up"
    end
  end
end
