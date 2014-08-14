class TileExploreDigestDecorator < TileDigestDecorator
  def email_site_link
    if Rails.env.development? or Rails.env.test?
      'http://localhost:3000' + h.explore_tile_preview_path(object)
    else
      h.explore_tile_preview_url(object)
    end 
  end
end
