class TileExploreDigestDecorator < TileDigestDecorator
  def email_site_link
    if Rails.env.development? or Rails.env.test?
      'http://localhost:3000' + h.explore_tile_preview_path(object, email_type: 'explore_digest', explore_token: context[:user].explore_token, tile_ids: context[:tile_ids])
    else
      h.explore_tile_preview_url(object, email_type: 'explore_digest', explore_token: context[:user].explore_token, tile_ids: context[:tile_ids])
    end
  end
end
