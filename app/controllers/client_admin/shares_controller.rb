class ClientAdmin::SharesController < ClientAdminBaseController
  def show
    @demo = current_user.demo
    @user = current_user
    tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
    @follow_up_emails = @demo.follow_up_digest_emails.scheduled
    @board_is_public = @demo.is_public
    @recipient_counts = get_recipient_counts

    @digest_tiles = @demo.digest_tiles(tile_digest_email_sent_at)
    @tiles_to_be_sent = @demo.digest_tiles(tile_digest_email_sent_at).count
    @tiles_digest_form = TilesDigestForm.new(current_user, session[:digest])

    digest_sent_modal

    prepend_view_path 'client_admin/users'
  end

  def show_first_active_tile
    @demo = current_user.demo

    @first_active_tile = @demo.tiles.active.order('activated_at asc').limit(1)
    render :layout => false
  end

  private

    def get_recipient_counts
      {
        all_user_email_recipient_count: @demo.users.non_site_admin.count,
        activated_user_email_recipient_count: @demo.claimed_user_count,
        all_user_sms_recipient_count: @demo.user_with_phone_number_count,
        activated_user_sms_recipient_count: @demo.claimed_user_with_phone_number_count
      }
    end

    def digest_sent_modal
      @digest_sent_type = session.delete(:digest_sent_type)
    end
end
