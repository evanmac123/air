class TilesDigestMailer < ActionMailer::Base

  helper :email                # loads 'app/helpers/email_helper.rb' & includes 'EmailHelper' into the View
  helper 'client_admin/tiles'  # ditto for 'tiles_helper.rb'

  has_delay_mail  # Some kind of monkey-patch workaround (not even sure need)

  def notify(user_id, tile_ids)
    @tile_ids = tile_ids
    @user = user_id

    mail  to:      @user.email_with_name,
          from:    'donotreply@hengage.com',
          subject: 'Newly-added H.Engage Tiles'
  end
end
