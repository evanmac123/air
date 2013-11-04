class TilesDigestMailer < ActionMailer::Base

  helper :email, :skin         # loads 'app/helpers/email_helper.rb' & includes 'EmailHelper' into the View. (Ditto for 'skin')
  helper 'client_admin/tiles'  # ditto for 'app/helpers/client_admin/tiles_helper.rb'

  has_delay_mail       # Some kind of monkey-patch workaround (not even sure need)

  include EmailHelper  # Well, the 'helper' above method might include it into the view, but it don't include it in here

  def noon
    Date.today.midnight.advance(hours: 12)
  end

  def notify_all_follow_up_from_delayed_job
    FollowUpDigestEmail.send_follow_up_digest_email.each { |followup| TilesDigestMailer.delay(run_at: noon).notify_all_follow_up(followup.id) }
  end

  def notify_all(demo, unclaimed_users_also_get_digest, follow_up_days, cutoff_time)
    tile_ids = demo.digest_tiles(cutoff_time).pluck(:id)
    user_ids = demo.users_for_digest(unclaimed_users_also_get_digest).pluck(:id)

    FollowUpDigestEmail.create!(demo_id:  demo.id,
                               tile_ids: tile_ids,
                               send_on:  Date.today + follow_up_days.days,
                               unclaimed_users_also_get_digest: unclaimed_users_also_get_digest) if follow_up_days > 0

    user_ids.each { |user_id| TilesDigestMailer.delay.notify_one(demo.id, user_id, tile_ids, 'New Tiles') }
  end

  def notify_all_follow_up(followup_id)
    followup = FollowUpDigestEmail.find followup_id

    tile_ids = followup.tile_ids
    user_ids = followup.demo.users_for_digest(followup.unclaimed_users_also_get_digest).pluck(:id)

    user_ids.reject! { |user_id| TileCompletion.user_completed_any_tiles?(user_id, tile_ids)}
    user_ids.each    { |user_id| TilesDigestMailer.delay.notify_one(followup.demo.id, user_id, tile_ids, "Don't Miss Your New Tiles", true) }

    followup.destroy
  end

  def notify_one(demo_id, user_id, tile_ids, subject, follow_up_email = false)
    @demo  = Demo.find demo_id
    @user  = User.find user_id

    @tiles = Tile.where(id: tile_ids).order('activated_at DESC')
    @follow_up_email = follow_up_email

    @invitation_url = @user.claimed? ? nil : invitation_url(@user.invitation_code, protocol: email_link_protocol, host: email_link_host)

    mail  to:      @user.email_with_name,
          from:    @demo.reply_email_address,
          subject: subject
  end
end
