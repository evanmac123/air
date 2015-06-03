class TileWeeklyActivityDecorator < TileDigestDecorator
  def email_site_link
    if Rails.env.development? or Rails.env.test?
			h.link_to client_admin_tile_tile_completions_url(presenter)
    else
			h.link_to client_admin_tile_tile_completions_url(presenter)
    end 
  end
end
