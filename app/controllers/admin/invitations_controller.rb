class Admin::InvitationsController < AdminBaseController
  def create
    @style = EmailStyling.new(get_image_url)
    @user = User.find_by_slug(params[:user_id])
    @user.invitation_method = "admin"
    @user.invite(nil, style: @style)
  end
end
