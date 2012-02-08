class UsersController < Clearance::UsersController
  layout "application"
  
  def index
    @friend_ids = current_user.friend_ids
    @other_users = User.where(['demo_id = ? AND id != ?', current_user.demo_id, current_user.id]).alphabetical
  end

  def show
    @user = User.find_by_slug(params[:id])
    @locations = @user.demo.locations
    @acts = @user.acts.in_user_demo.displayable_to_user(current_user).recent(10)
    @viewing_self = signed_in? && current_user == @user
    @viewing_other = signed_in? && current_user != @user

    @current_link_text = "My Profile" if @viewing_self
  end
end
