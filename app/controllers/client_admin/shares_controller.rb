class ClientAdmin::SharesController < ClientAdminBaseController
  def show
    @demo = current_user.demo
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
    @digest_tiles  = @demo.digest_tiles(@tile_digest_email_sent_at)
    @follow_up_emails = @demo.follow_up_digest_emails.order("send_on ASC")
    @suppress_tile_stats = true
    @board_is_public = @demo.is_public
    @tiles_to_be_sent = @demo.digest_tiles(@demo.tile_digest_email_sent_at).count
  end
end
