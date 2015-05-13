class ClientAdmin::AllowedToSuggestUsersController < ClientAdminBaseController
  def show
    demo = current_user.demo
    user = demo.users.find(params[:id])

    render json: {userRow: user_row(user)}
  end

  protected

  def user_row(user)
    render_to_string("client_admin/allowed_to_suggest_users/_user", 
      locals: {user: user}, 
      layout: false
    )
  end
end