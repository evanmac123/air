class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  def create
    @demo = current_user.demo

    follow_up_days = FollowUpDigestEmail.follow_up_days(params[:follow_up_day])
    # Need to do this because the param is the string "true" or "false"... and the string "false" is true
    unclaimed_users_also_get_digest = (params[:digest_send_to] == 'true' ? true : false)

    cutoff_time = @demo.tile_digest_email_sent_at
    TilesDigestMailer.delay.notify_all @demo, unclaimed_users_also_get_digest, follow_up_days, cutoff_time

    @demo.update_attributes tile_digest_email_sent_at: Time.now, unclaimed_users_also_get_digest: unclaimed_users_also_get_digest

    flash[:success] = "Tiles digest email was sent"
    redirect_to client_admin_tiles_path
  end
end
