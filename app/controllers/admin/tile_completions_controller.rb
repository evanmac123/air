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
    Tile.reset_tiles_for_user_within_an_arbitrary_demo(current_user, demo)
    add_success "#{current_user.name}'s tiles for #{demo.name} have been reset. Associated acts have been destroyed"
    redirect_to :back
  end

end
