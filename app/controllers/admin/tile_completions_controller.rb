class Admin::TileCompletionsController < AdminBaseController

  def create 
    tile = Tile.find(params[:tile_id])
    user = User.where(slug: params[:user_slug]).first
    if tile && user
      tile.satisfy_for_user!(user)
      add_success "#{tile.name} manually completed for #{user.name}"
    end
    redirect_to :back
  end
end
