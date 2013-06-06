class TilesDigestMailer < ActionMailer::Base
  helper 'client_admin/tiles'

  has_delay_mail  # Some kind of monkey-patch workaround

  def notify(demo)
    @demo = demo

    mail  to:      'all demo.users',
          from:    'donotreply@hengage.com',
          subject: 'Newly-added H.Engage Tiles'
  end
end
