class TilesDigestMailer < ActionMailer::Base

  helper :email                # loads 'app/helpers/email_helper.rb' & includes 'EmailHelper' into the View
  helper 'client_admin/tiles'  # ditto for 'tiles_helper.rb'

  has_delay_mail       # Some kind of monkey-patch workaround (not even sure need)

  include EmailHelper  # Well, the 'helper' above method might include it into the view, but it don't include it in here


  def notify_all_from_delayed_job()
    Demo.send_digest_email.each { |demo| TilesDigestMailer.delay.notify_all(demo.id) }
  end

  def notify_all(demo_id)
    demo = Demo.find demo_id

    user_ids = demo.users.pluck(:id)
    tile_ids = demo.digest_tiles.pluck(:id)

    user_ids.each { |user_id| TilesDigestMailer.delay.notify_one(user_id, tile_ids) }

    demo.update_attributes tile_digest_email_sent_at: Time.now
  end

  def notify_one(user_id, tile_ids)
    @user  = User.find user_id
    @tiles = Tile.find tile_ids

    # For the footer...
    @invitation_url = @user.claimed? ? nil : invitation_url(@user.invitation_code, protocol: email_link_protocol, host: email_link_host)

    mail  to:      @user.email_with_name,
          from:    'donotreply@hengage.com',
          subject: 'New Tiles'
  end
end
