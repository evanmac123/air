class TileExploreDigestDecorator < TileDigestDecorator
  def email_site_link
    if Rails.env.development? or Rails.env.test?
      'http://localhost:3000' + h.explore_tile_preview_path(object, explore_token: context[:user].explore_token)
    else
      h.explore_tile_preview_url(object, explore_token: context[:user].explore_token)
    end 
  end
end
