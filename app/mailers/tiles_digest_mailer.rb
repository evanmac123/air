class TilesDigestMailer < ActionMailer::Base

  helper :email, :skin         # loads 'app/helpers/email_helper.rb' & includes 'EmailHelper' into the View. (Ditto for 'skin')
  helper 'client_admin/tiles'  # ditto for 'app/helpers/client_admin/tiles_helper.rb'

  has_delay_mail       # Some kind of monkey-patch workaround (not even sure need)

  include EmailHelper  # Well, the 'helper' above method might include it into the view, but it don't include it in here
  include ClientAdmin::TilesHelper # and ditto

  layout nil#'mailer'

  def noon
    Date.today.midnight.advance(hours: 12)
  end

  def notify_all_follow_up_from_delayed_job
    FollowUpDigestEmail.send_follow_up_digest_email.each { |followup| TilesDigestMailer.delay(run_at: noon).notify_all_follow_up(followup.id) }
  end

  def notify_all(demo, unclaimed_users_also_get_digest, tile_ids, custom_message)
    user_ids = demo.users_for_digest(unclaimed_users_also_get_digest).pluck(:id)

    user_ids.each { |user_id| TilesDigestMailer.delay.notify_one(demo.id, user_id, tile_ids, 'New Tiles', false, custom_message) }
  end

  def notify_all_follow_up(followup_id)
    followup = FollowUpDigestEmail.find followup_id

    tile_ids = followup.tile_ids
    user_ids = followup.demo.users_for_digest(followup.unclaimed_users_also_get_digest).pluck(:id)

    user_ids.reject! { |user_id| TileCompletion.user_completed_any_tiles?(user_id, tile_ids)}
    user_ids.each    { |user_id| TilesDigestMailer.delay.notify_one(followup.demo.id, user_id, tile_ids, "Don't Miss Your New Tiles", true, nil) }

    followup.destroy
  end

  # custom_from can have send value 'Hisham via Airbo <@demo.reply_email_address>'
  def notify_one(demo_id, user_id, tile_ids, subject, follow_up_email, 
      custom_message, custom_from=nil, is_new_invite = nil)
    @demo  = Demo.find demo_id
    @user  = User.find user_id
    return nil unless @user.email.present? # no wasting our time trying to email people for whom we don't have an address

    @tiles = Tile.where(id: tile_ids).order('activated_at DESC')
    @follow_up_email = follow_up_email
    @custom_message = custom_message
    if is_new_invite
      @title = "Join my #{@demo.name}"      
      @email_heading = "Join my #{@demo.name}"
    else
      @title = @email_heading = digest_email_heading
    end

    @email_type = find_email_type follow_up_email
    ping_on_digest_email @email_type, @user

    @invitation_url = @user.claimed? ? nil : invitation_url(@user.invitation_code, protocol: email_link_protocol, host: email_link_host)
    mail  to:      @user.email_with_name,
          from:    custom_from || @demo.reply_email_address,
          subject: subject
  end

  def ping_on_digest_email email_type, user
    TrackEvent.ping( "Email Sent", {email_type: ping_message[email_type]}, user )
  end

  def ping_message
    {
      "digest_old_v" => "Digest  - v. Pre 6/13/14",
      "digest_new_v" => "Digest - v. 6/15/14",
      "follow_old_v" => "Follow-up - v. pre 6/13/14",
      "follow_new_v" => "Follow-up - v. 6/15/14"
    }
  end

  def find_email_type follow_up_email 
    digest_type = follow_up_email ? "follow" : "digest"
    digest_type + "_new_v"
  end
end
