class TilesDigestMailer < ActionMailer::Base
  helper 'client_admin/tiles'

  # todo Seems to always be done... but do we still need to do these things?
  #has_delay_mail  # Some kind of monkey-patch workaround
  #helper :email   # Loads app/helpers/email_helper.rb & includes EmailHelper into the VIEW

  def notify(demo)
    @digest_tiles = demo.digest_tiles

    # Need to use 'path' method which gives full path, not 'url' method which
    # gives relative path, i.e. ass-backwards from the Rails' routes helpers
    @digest_tiles.each do |tile|
      attachments.inline["tile_#{tile.id}"] = File.read(tile.thumbnail.path)
    end

    mail  to:      'all demo.users',
          from:    'donotreply@hengage.com',
          subject: 'Newly-added H.Engage Tiles'
  end
end
