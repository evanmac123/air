class TilesDigestMailer < ActionMailer::Base

  # todo What about the instance variables accessed by the unsubscribe footer?

  helper :email                   # loads 'app/helpers/email_helper.rb' & includes 'EmailHelper' into the View
  helper 'client_admin/tiles'     # ditto for 'tiles_helper.rb'

  has_delay_mail  # Some kind of monkey-patch workaround

  def notify(demo)
    @demo = demo

    mail  to:      'joe@blow.com',
          from:    'donotreply@hengage.com',
          subject: 'Newly-added H.Engage Tiles'
  end
end
