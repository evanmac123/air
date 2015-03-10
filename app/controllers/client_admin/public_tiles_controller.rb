class ClientAdmin::PublicTilesController < ClientAdminBaseController
  before_filter :get_tile

  def update
    if params[:tile_public_form].present?
      is_sharable = params[:tile_public_form][:is_sharable]
      unless is_sharable.nil?
        @tile.update_sharable_attr is_sharable
      else
        tile_public_form = TilePublicForm.new(@tile, params[:tile_public_form])
        tile_public_form.save
      end
    end

    render nothing: true
  end

  protected

  def get_tile
    @tile = current_user.demo.tiles.find params[:id]
  end
end
