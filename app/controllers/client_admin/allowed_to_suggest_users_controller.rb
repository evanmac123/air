class ClientAdmin::AllowedToSuggestUsersController < ClientAdminBaseController
  def destroy
    demo = current_user.demo
    user = demo.users.find(params[:id])
    user.update_allowed_to_make_tile_suggestions false, demo

    redirect_to :back
  end
end