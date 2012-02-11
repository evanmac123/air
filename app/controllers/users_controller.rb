class UsersController < Clearance::UsersController
  layout "application"
  
  def index
    @other_users = User.claimed.where(['demo_id = ? AND id != ?', current_user.demo_id, current_user.id]).alphabetical
    @friend_ids = current_user.friend_ids
    @search_link_text = "our search bar"
    text = params[:search_string]
    if text
      @search_string = text
      text = text.downcase
      demo = current_user.demo
      names = @other_users.where("LOWER(name) like ?", "%" + text + "%")
      slugs = @other_users.where("LOWER(sms_slug) like ?", "%" + text + "%")
      emails = @other_users.where("LOWER(email) like ?", "%" + text + "%")
      @other_users = names + slugs + emails
      @search_link_text = "refining your search"
    end
    user_limit = 50
    @users_cropped = user_limit if @other_users.length > user_limit
    @other_users = @other_users[0,user_limit]
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
