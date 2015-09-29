class TileWeeklyActivityDecorator < TileDigestDecorator
	def email_site_link
		h.client_admin_tile_tile_stats_url(object)
	end
end
