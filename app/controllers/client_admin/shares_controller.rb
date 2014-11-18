class ClientAdmin::SharesController < ClientAdminBaseController
  def show
    @demo = current_user.demo
    @user = current_user    
    tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
    @follow_up_emails = @demo.follow_up_digest_emails.order("send_on ASC")
    @board_is_public = @demo.is_public
    @all_users = @demo.users.where(is_site_admin: false).count
    @activated_users = @demo.users.claimed.where(is_site_admin: false).count - 1 #need to exclude the current user

    if (!@demo.has_normal_users? || @demo.tile_completions.empty?) && current_user.show_onboarding?
      #need to show show_invite_users with tiles active so far
      @digest_tiles = @demo.digest_tiles(nil)
      @tiles_to_be_sent = @demo.digest_tiles(nil).count
      @show_invite_users = @tiles_to_be_sent > 0
    else
      @digest_tiles = @demo.digest_tiles(tile_digest_email_sent_at)
      @tiles_to_be_sent = @demo.digest_tiles(tile_digest_email_sent_at).count    
      @show_invite_users = false
    end
    
    if @demo.non_activated? && current_user.show_onboarding?
      TrackEvent.ping_page('Page Locked', {}, current_user)
    else
      ping_page("Manage - Share Page", current_user)
    end
    prepend_view_path 'client_admin/users'
  end
  
  def show_first_active_tile
    @demo = current_user.demo
    
    @first_active_tile = @demo.tiles.active.order('activated_at asc').limit(1)
    render :layout => false
  end
  
  def added_valid_user
    TrackEvent.ping_action('Share - Add First Users', 'Added Valid User', current_user)
    render nothing: true
  end
  
  def number_of_valid_users_added
    TrackEvent.ping_action('Share - Add First Users', 'Number of valid users added', current_user, num_valid_users: params[:num_valid_users])
    render nothing: true    
  end
  def successfully_added_users
    TrackEvent.ping_action('Share - Add First Users', 'Successfully Added Users', current_user)
    render nothing: true
  end
  
  def clicked_skip
    TrackEvent.ping_action('Share - Add First Users', 'Clicked Skip link', current_user)
    render nothing: true
  end
  
  def clicked_mail_to
    TrackEvent.ping_action('Share - Add First Users', 'Clicked To upload a list, contact us', current_user)
    render nothing: true
  end
  
  def got_error
    TrackEvent.ping_action('Share - Add First Users', 'Got Error', current_user, type: params[:error_message])
    render nothing: true
  end
  
  def changed_message
    TrackEvent.ping_action('Share - Send Invitation', "Changed message", current_user)
    render nothing: true
  end
  
  def clicked_add_more_users
    TrackEvent.ping_action('Share - Send Invitation', "Clicked Add More Users", current_user)
    render nothing: true
  end
  
  def successfully_sent
    TrackEvent.ping_action('Share - Send Invitation', "Successfully Sent", current_user)
    render nothing: true
  end
  
  def clicked_success_mail
    TrackEvent.ping_action('Share - Invitation Sent Confirmation', "Clicked Email Share Icon", current_user)
    render nothing: true
  end
  
  def clicked_success_twitter
    TrackEvent.ping_action('Share - Invitation Sent Confirmation', "Clicked Twitter Share Icon", current_user)
    render nothing: true
  end
  
  def clicked_share_mail
    TrackEvent.ping_action('Share - Using Link Only', "Clicked Email Share Icon", current_user)
    render nothing: true
  end
  
  def clicked_share_twitter
    TrackEvent.ping_action('Share - Using Link Only', "Clicked Twitter Share Icon", current_user)
    render nothing: true
  end    
  
  def clicked_add_users
    TrackEvent.ping_action('Share - Using Link Only', "Clicked Add Users", current_user)
    render nothing: true    
  end
  
  def selected_public_board    
    if (params[:path]||'').to_sym == :success_share_digest
      TrackEvent.ping_action('Share - Invitation Sent Confirmation', "Selected share link", current_user)
    else
      TrackEvent.ping_action('Share - Using Link Only', "Selected share link", current_user)
    end
    render nothing: true    
  end

end
