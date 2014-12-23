class ClientAdmin::SharesController < ClientAdminBaseController
  def show
    @demo = current_user.demo
    @user = current_user    
    tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
    @follow_up_emails = @demo.follow_up_digest_emails.order("send_on ASC")
    @board_is_public = @demo.is_public
    @all_users = @demo.users.where(is_site_admin: false).count
    @activated_users = @demo.users.claimed.where(is_site_admin: false).count - 1 #need to exclude the current user

    @digest_tiles = @demo.digest_tiles(tile_digest_email_sent_at)
    @tiles_to_be_sent = @demo.digest_tiles(tile_digest_email_sent_at).count    
    
    ping_page("Manage - Share Page", current_user)
    prepend_view_path 'client_admin/users'
  end
  
  def show_first_active_tile
    @demo = current_user.demo
    
    @first_active_tile = @demo.tiles.active.order('activated_at asc').limit(1)
    render :layout => false
  end
end
