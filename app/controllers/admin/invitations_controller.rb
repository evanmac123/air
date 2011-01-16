class Admin::InvitationsController < AdminBaseController
  def create
    @user = User.find(params[:user_id])
    @user.invite
  end
end
