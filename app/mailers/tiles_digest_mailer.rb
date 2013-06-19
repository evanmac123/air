class TilesDigestMailer < ActionMailer::Base

  helper :email                # loads 'app/helpers/email_helper.rb' & includes 'EmailHelper' into the View
  helper 'client_admin/tiles'  # ditto for 'tiles_helper.rb'

  has_delay_mail  # Some kind of monkey-patch workaround (not even sure need)

  def notify_all(user_ids, tile_ids)
    user_ids.each { |user_id| TilesDigestMailer.delay.notify_one(user_id, tile_ids) }
  end

  def notify_one(user_id, tile_ids)
    @user  = User.find user_id
    @tiles = Tile.find tile_ids

    mail  to:      @user.email_with_name,
          from:    'donotreply@hengage.com',
          subject: 'New Tiles'
  end
end
