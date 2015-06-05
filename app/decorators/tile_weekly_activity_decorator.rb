class TileWeeklyActivityDecorator < TileDigestDecorator
	def email_site_link
		h.client_admin_tile_tile_completions_url(SingleTilePresenter.new(object, :html))
	end
end
