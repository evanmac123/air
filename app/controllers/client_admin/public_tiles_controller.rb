class ClientAdmin::PublicTilesController < ClientAdminBaseController
  before_filter :get_tile

  def update
    if params[:tile_builder_form].present?
      if params[:tile_builder_form][:is_sharable].present?
        @tile.update_attribute(:is_sharable, params[:tile_builder_form][:is_sharable])
      elsif @tile.is_sharable?
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
=begin
  def allowed_builder_params
    {} unless params[:tile_builder_form].present?

    builder_params = @tile.attributes
    if params[:tile_builder_form][:is_sharable].present?
      builder_params[:is_sharable] = params[:tile_builder_form][:is_sharable]
    end
    if params[:tile_builder_form][:is_public].present?
      builder_params[:is_public] = params[:tile_builder_form][:is_public]
    end
    if params[:tile_builder_form][:is_copyable].present?
      builder_params[:is_copyable] = params[:tile_builder_form][:is_copyable]
    end
    if params[:tile_builder_form][:tile_tag_ids].present?
      builder_params[:tile_tag_ids] = params[:tile_builder_form][:tile_tag_ids]
    end
    builder_params
  end
=end
end