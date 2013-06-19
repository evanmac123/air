class TilesDigestMailer < ActionMailer::Base

  helper :email                # loads 'app/helpers/email_helper.rb' & includes 'EmailHelper' into the View
  helper 'client_admin/tiles'  # ditto for 'tiles_helper.rb'

  has_delay_mail       # Some kind of monkey-patch workaround (not even sure need)

  include EmailHelper  # Well, the 'helper' above method might include it into the view, but it don't include it in here


  def notify_all(user_ids, tile_ids)
    user_ids.each { |user_id| TilesDigestMailer.delay.notify_one(user_id, tile_ids) }
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
