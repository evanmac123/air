class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController

  before_filter :authorize_digest

  def create
    @tiles_digest_form = TilesDigestForm.new(current_user, params[:digest])

    if params[:digest_type] == "test_digest"
      current_board.set_tile_email_draft(params[:digest])
      @tiles_digest_form.submit_send_test_digest
    else
      current_board.clear_tile_email_draft
      @tiles_digest_form.submit_schedule_digest_and_followup
    end

    session[:digest_sent_type] = digest_sent_type

    redirect_to :back
  end

  def save
    current_board.set_tile_email_draft(params[:digest])
    render json: current_board.get_tile_email_draft
  end

  private

    def authorize_digest
      unless current_user.demo_id == params[:digest][:demo_id].to_i
        flash[:failure] = "Oops, looks like you tried to save or send a Tile Email in a board with an expired session. Please try again by switching into the right board."

        respond_to do |format|
          format.html { redirect_to :back }
          format.json { render_json_access_denied }
        end
      end
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
