class ClientAdmin::SharableTilesController < ClientAdminBaseController
  before_filter :get_tile

  def update
    if params[:multiple_choice_tile].present?
      @tile.update_attribute :is_sharable, params[:multiple_choice_tile][:is_sharable]
    end
    render nothing: true
  end

  protected

  def get_tile
    @tile = current_user.demo.tiles.find params[:id]
  end
end
