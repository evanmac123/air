class ClientAdmin::TilesFollowUpEmailController < ClientAdminBaseController
  before_filter :get_followup, only:[:update, :destroy]

  def update
    if params[:now].present? 
      @follow_up_email.trigger_deliveries
      #@follow_up_email.destroy
      head :ok
    else
      @follow_up_email.update_attributes(params.permit(:original_digest_subject, :send_on))
      @follow_up_email.save
      render json: update_response
    end

  end

  def destroy
    #@follow_up_email.destroy
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
    @follow_up_email.as_json(root: false, only: [:original_digest_subject,  :send_on])
  end
end
