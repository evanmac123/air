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

    session[:digest_sent_type] = digest_sent_type

    redirect_to :back
  end

  private

    def save_digest_form_params
      session[:digest] = params[:digest]
    end

    def digest_sent_type
      if params[:digest_type] == "test_digest"
        test_digest_sent_type
      else
        "digest_delivered"
      end
    end

    def test_digest_sent_type
      type = "test_digest"
      type += "_and_follow_up" if @tiles_digest_form.with_follow_up?
      type += "_with_sms" if @tiles_digest_form.include_sms
      type
    end
end
