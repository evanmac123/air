class ClientAdmin::TilesDigestPreviewsController < ClientAdminBaseController
  layout false
  prepend_before_filter :allow_same_origin_framing

  def sms
    @tile = Tile.find(31675)
    @subject = "New Tiles!"
    @digest = { tile: @tile }
  end
end
