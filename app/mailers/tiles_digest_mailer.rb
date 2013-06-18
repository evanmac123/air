class TilesDigestMailer < ActionMailer::Base
  TEST_EMAIL = 'connie@hengage.com'

  helper :email                # loads 'app/helpers/email_helper.rb' & includes 'EmailHelper' into the View
  helper 'client_admin/tiles'  # ditto for 'tiles_helper.rb'

  has_delay_mail  # Some kind of monkey-patch workaround (not even sure need)

  def notify(tile_ids)
    @tile_ids = tile_ids

    mail  to:      TEST_EMAIL,
          from:    'donotreply@hengage.com',
          subject: 'Newly-added H.Engage Tiles'
  end
end
