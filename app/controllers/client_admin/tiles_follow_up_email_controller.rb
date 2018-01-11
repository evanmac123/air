class ClientAdmin::TilesFollowUpEmailController < ClientAdminBaseController
  before_action :get_followup, only:[:edit, :update, :destroy]

  SAVE_SUCCESS = "Your follow up email has been updated"
  SEND_NOW_SUCCESS = "Your follow up email has been rescheduled for immediate delivery"
  DELETE_SUCCESS = "Your follow up email has been canceled"

  def edit
    if request.xhr?
      render partial: "follow_up_email_form", layout: false
    end
  end


  def update
    if params[:now].present?
      @follow_up_email.trigger_deliveries
      js_flash SEND_NOW_SUCCESS
      head :ok
    else
      @follow_up_email.update_attributes(permitted_params)
      js_flash SAVE_SUCCESS
      render json: update_response
    end
  end

  def destroy
    @follow_up_email.destroy
    js_flash DELETE_SUCCESS
    render json: delete_response
  end

  private

  def get_followup
    @follow_up_email = current_user.demo.follow_up_digest_emails.find params[:id]
  end

  def send_now
    @follow_up_email = current_user.demo.follow_up_digest_emails.find params[:id]
  end

  def schedule_followup_cancelled_ping
    ping 'Followup - Cancelled', {}, current_user
  end

  def delete_response
    @follow_up_email.as_json(root: false, only: [:id, :demo_id, :send_on])
  end

  def update_response
    {
      subject: @follow_up_email.subject_before_sent,
      send_on: @follow_up_email.send_on
    }
  end

  def permitted_params
    params.require(:follow_up_digest_email).permit(:subject, :alt_subject, :send_on)
  end

  def js_flash(msg)
    response.headers["X-Message"] = msg
  end
end
