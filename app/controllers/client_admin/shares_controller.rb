class ClientAdmin::SharesController < ClientAdminBaseController
  def show
    @demo = current_user.demo
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
    @digest_tiles  = @demo.digest_tiles(@tile_digest_email_sent_at)
    @follow_up_emails = @demo.follow_up_digest_emails
  end
end
