class ClientAdmin::TilesDigestPreviewsController < ClientAdminBaseController
  layout false

  def sms
    @tile = first_tile_for_digest
    @digest = { tile: @tile }
  end

  private

    def first_tile_for_digest
      current_user.demo.digest_tiles.ordered_by_position.first
    end
end
