class TileExploreDigestDecorator < TileDigestDecorator
  def email_site_link
    url = h.explore_tile_preview_path(object)
    url.prepend('http://localhost:3000') if Rails.env.development? or Rails.env.test?
    url
  end
end
