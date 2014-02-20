class ClientAdmin::SharesController < ClientAdminBaseController
  def show
    @demo = current_user.demo
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
    @digest_tiles  = @demo.digest_tiles(@tile_digest_email_sent_at)
    @follow_up_emails = @demo.follow_up_digest_emails.order("send_on ASC")
    @suppress_tile_stats = false #TODO WARN CHANGE BACK TO true after completing show-completion-details(https://trello.com/c/lTPrVBla/46-as-a-creator-i-want-to-know-who-completed-my-tiles)
    @board_is_public = @demo.is_public
  end
end
