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

  def destroy
    demo = Demo.find(params[:demo_id])
    user = params[:user_id] ? User.find(params[:user_id]) : current_user
    user.reset_tiles(demo)
    add_success "#{user.name}'s tiles for #{demo.name} have been reset. Associated acts have been destroyed"
    redirect_to :back
  end
end
