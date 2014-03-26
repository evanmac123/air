class Admin::TileCompletionsController < AdminBaseController
  def destroy
    demo = Demo.find(params[:demo_id])
    user = params[:user_id] ? User.find(params[:user_id]) : current_user
    user.reset_tiles(demo)
    add_success "#{user.name}'s tiles for #{demo.name} have been reset. Associated acts have been destroyed"
    redirect_to :back
  end
end
