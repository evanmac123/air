module EmailInterpolations
  module TileDigestUrl
    include SelfClosingTag
    include ClientAdmin::TilesHelper
    include EmailHelper

    def interpolate_tile_digest_url(user, text)
      interpolate_self_closing_tag('tile_digest_url', email_site_link(user), text).html_safe
    end
  end
end
