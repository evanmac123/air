class ClientAdmin::SharesController < ClientAdminBaseController
  def show
    @demo = current_user.demo
    @user = current_user    
    tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
    @follow_up_emails = @demo.follow_up_digest_emails.order("send_on ASC")
    @suppress_tile_stats = false
    @board_is_public = @demo.is_public

    if (!@demo.has_normal_users? || @demo.tile_completions.empty?)
      #need to show show_invite_users with tiles active so far
      @digest_tiles = @demo.digest_tiles(nil)
      @tiles_to_be_sent = @demo.digest_tiles(nil).count
      @show_invite_users = @tiles_to_be_sent > 0
    else
      @digest_tiles = @demo.digest_tiles(tile_digest_email_sent_at)
      @tiles_to_be_sent = @demo.digest_tiles(tile_digest_email_sent_at).count    
      @show_invite_users = false
    end
    
    if @demo.non_activated?
      TrackEvent.orientation_ping_page('Orientation - Page Locked')
    else
      TrackEvent.orientation_ping_page('Orientation - Share') 
    end
    prepend_view_path 'client_admin/users'
  end
  
  def show_first_active_tile
    @demo = current_user.demo
    
    @first_active_tile = @demo.tiles.active.order('activated_at asc').limit(1)
    render :layout => false
  end
  
  def added_valid_user
    TrackEvent.orientation_ping('Share - Add First Users', 'Added Valid User')
    render nothing: true
  end
  
  def clicked_preview_invitation
    TrackEvent.orientation_ping('Share - Add First Users', 'Clicked Preview Invitation button')
    render nothing: true
  end
  
  def clicked_skip
    TrackEvent.orientation_ping('Share - Add First Users', 'Clicked Skip link')
    render nothing: true
  end
  
  def clicked_mail_to
    TrackEvent.orientation_ping('Share - Add First Users', 'Clicked To upload a list, contact us')
    render nothing: true
  end
  
  def got_error(error)
    TrackEvent.orientation_ping('Share - Add First Users', "Got error: #{}")
    render nothing: true
  end
  
  def changed_message
    TrackEvent.orientation_ping('Share - Send Invitation', "Changed message")
    render nothing: true
  end
  
  def clicked_add_more_users
    TrackEvent.orientation_ping('Share - Send Invitation', "Clicked Add More Users")
    render nothing: true
  end
  
  def clicked_send
    TrackEvent.orientation_ping('Share - Send Invitation', "Clicked Send")
    render nothing: true
  end
  
  def clicked_success_mail
    TrackEvent.orientation_ping('Share - Invitation Sent Confirmation', "Clicked Email Share Icon")
    render nothing: true
  end
  
  def clicked_success_twitter
    TrackEvent.orientation_ping('Share - Invitation Sent Confirmation', "Clicked Twitter Share Icon")
    render nothing: true
  end
  
  def clicked_share_mail
    TrackEvent.orientation_ping('Share - Using Link Only', "Clicked Email Share Icon")
    render nothing: true
  end
  
  def clicked_share_twitter
    TrackEvent.orientation_ping('Share - Using Link Only', "Clicked Twitter Share Icon")
    render nothing: true
  end
  
  def clicked_got_it_on_first_completion
    TrackEvent.orientation_ping('Tiles Page', "Pop Over - clicked Got It")
    render nothing: true
  end
end
