class Admin::InvitationsController < AdminBaseController
  def create
    @user = User.find_by(slug: params[:user_id])
    @user.invitation_method = "admin"
    @user.invite
  end
end
