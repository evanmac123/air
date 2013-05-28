class TilesDigestMailer < ActionMailer::Base

  # todo Seems to always be done... but do we still need to do these things?
  #has_delay_mail  # Some kind of monkey-patch workaround
  #helper :email   # Loads app/helpers/email_helper.rb & includes EmailHelper into the VIEW

  def notify
    @email_title = 'Tiles Digest'

    mail  to:      'all demo.users',
          from:    'donotreply@hengage.com',
          subject: 'Newly-added H.Engage Tiles'
  end
end
