class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  def create
    @demo = current_user.demo

# todo not just parms[:follow_up] - need to see if checkbox checked
    # todo remove 'follow_up_digest_email_days' from dbase and pass in as param to 'notify_all' (0 if unchecked)
    TilesDigestMailer.delay.notify_all @demo.id, @demo.digest_tiles.pluck(:id), params[:follow_up]

    @demo.update_attributes tile_digest_email_sent_at: Time.now, unclaimed_users_also_get_digest: params[:send_to]

    flash[:success] = "Tiles digest email was sent"
    redirect_to client_admin_tiles_path
  end
end
