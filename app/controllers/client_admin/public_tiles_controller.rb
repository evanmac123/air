class ClientAdmin::PublicTilesController < ClientAdminBaseController
  before_filter :get_tile

  def update
    if params[:tile_builder_form].present?
      if params[:tile_builder_form][:is_sharable].present?
        @tile.update_attribute(:is_sharable, params[:tile_builder_form][:is_sharable])
      else
        tile_builder_form = @tile.form_builder_class.new(@tile.demo, 
                            parameters: params[:tile_builder_form], 
                            tile: @tile)
        tile_builder_form.update_public_attributes
      end
    end

    render nothing: true
  end

  protected

  def get_tile
    @tile = current_user.demo.tiles.find params[:id]
  end
end