class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  before_filter :get_demo

  def create
    # Grab all of the tiles now because we're gonna be resetting the 'tile_digest_email_sent_at' real soon...
    tile_ids = @demo.digest_tiles.pluck(:id)

    TilesDigestMailer.delay.notify_all(@demo.id, tile_ids)

    @demo.update_attributes tile_digest_email_sent_at: Time.now

    flash[:success] = "Tiles digest email was sent"
    redirect_to client_admin_tiles_path
  end

  def update
    case
      when params[:send_on]   then update_send_on
      when params[:send_to]   then update_send_to
      when params[:follow_up] then update_follow_up
    end
  end

  private

  def get_demo
    @demo = current_user.demo
  end

  def update_send_on
    @demo.update_attributes tile_digest_email_send_on: params[:send_on]
    render text: "Send-on day updated to #{@demo.tile_digest_email_send_on}"
  end

  def update_send_to
    @demo.update_attributes(unclaimed_users_also_get_digest: params[:send_to])

    feedback = if params[:send_to] == 'true'
      "All users will get digest emails"
    else
      "Only joined users will get digest emails"
    end

    render text: feedback
  end

  def update_follow_up
    @demo.update_attributes follow_up_digest_email_days: params[:follow_up].to_i

    feedback = params[:follow_up] == '0' ? 'Follow-up digest email will not be sent' :
                                           "Follow-up digest email will be sent #{params[:follow_up]} #{params[:follow_up] == '1' ? 'day' : 'days'} after the original"
    render text: feedback
  end
end
