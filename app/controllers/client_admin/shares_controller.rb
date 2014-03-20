class ClientAdmin::SharesController < ClientAdminBaseController
  def show
    @demo = current_user.demo
    @user = current_user    
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
    @digest_tiles = @demo.digest_tiles(@tile_digest_email_sent_at)
    @follow_up_emails = @demo.follow_up_digest_emails.order("send_on ASC")
    @suppress_tile_stats = false
    @board_is_public = @demo.is_public

    @show_invite_users = @demo.active_tiles.count > 0 && @demo.users.non_admin_claimed.count < 1    
    @tiles_to_be_sent = @demo.digest_tiles(@demo.tile_digest_email_sent_at).count
    @show_invite_users = (@tiles_to_be_sent > 0) && (!@demo.has_normal_users?)

    prepend_view_path 'client_admin/users'
  end
  
  def show_first_active_tile
    @demo = current_user.demo
    
    @first_active_tile = @demo.tiles.active.order('activated_at asc').limit(1)
    render :layout => false
  end
end
