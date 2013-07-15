class TilesDigestMailer < ActionMailer::Base

  helper :email, :skin         # loads 'app/helpers/email_helper.rb' & includes 'EmailHelper' into the View. (Ditto for 'skin')
  helper 'client_admin/tiles'  # ditto for 'app/helpers/client_admin/tiles_helper.rb'

  has_delay_mail       # Some kind of monkey-patch workaround (not even sure need)

  include EmailHelper  # Well, the 'helper' above method might include it into the view, but it don't include it in here

  def notify_all_from_delayed_job
    noon = Date.today.midnight.advance(hours: 12)
    Demo.send_digest_email.each { |demo| TilesDigestMailer.delay(run_at: noon).notify_all(demo.id) }
  end

  def notify_all(demo_id, tile_ids = [])
    demo = Demo.find demo_id

    user_ids = demo.users.pluck(:id)

    # Called from controller/view "Send Now" => 'tile_ids' will be supplied.
    # Called from weekly cron-job method above => need to find 'tile_ids' ourselves...
    # ... unless the user has changed the 'send_on_day' for this demo, e.g. if the email was scheduled to
    # go out on Monday and it is Monday (or else we wouldn't be executing this method) and he says
    # "Oh shit, I don't want this sucker to go out!" he can simply set the 'send_on_day' to 'Never' and go
    # back to his 5-martini lunch.
    if tile_ids.empty?
      return if demo.tile_digest_email_send_on != Date::DAYNAMES[Date.today.wday]
      tile_ids = demo.digest_tiles.pluck(:id)
    end

    user_ids.each { |user_id| TilesDigestMailer.delay.notify_one(demo_id, user_id, tile_ids) }

    demo.update_attributes tile_digest_email_sent_at: Time.now
  end

  def notify_one(demo_id, user_id, tile_ids)
    @demo  = Demo.find demo_id
    @user  = User.find user_id
    @tiles = Tile.find tile_ids

    # For the footer...
    @invitation_url = @user.claimed? ? nil : invitation_url(@user.invitation_code, protocol: email_link_protocol, host: email_link_host)

    mail  to:      @user.email_with_name,
          from:    @demo.reply_email_address,
          subject: 'New Tiles'
  end
end
