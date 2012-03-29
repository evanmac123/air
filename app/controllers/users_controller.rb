class UsersController < Clearance::UsersController
  layout "application"
  
  def index
  
    @friend_ids = current_user.friend_ids
    @search_link_text = "our search bar"
    text = params[:search_string]
    if text
      @search_string = text
      text = text.downcase.strip.gsub(/\s+/, ' ')
      demo = current_user.demo
      @other_users = User.claimed.where(['demo_id = ? AND id != ?', current_user.demo_id, current_user.id]).alphabetical
      names = @other_users.where("LOWER(name) like ?", "%" + text + "%")
      slugs = @other_users.where("LOWER(sms_slug) like ?", "%" + text + "%")
      emails = @other_users.where("LOWER(email) like ?", "%" + text + "%")
      @other_users = names + slugs + emails
      @other_users.uniq!
      @search_link_text = "refining your search"
      user_limit = 50
      @users_cropped = user_limit if @other_users.length > user_limit && @search_string
      @other_users = @other_users[0,user_limit]
    end
    invoke_tutorial
  end

  def show
    @user = User.find_by_slug(params[:id])
    @locations = @user.demo.locations
    @acts = @user.acts.in_user_demo.displayable_to_user(current_user).recent(10)
    @viewing_self = signed_in? && current_user == @user
    @viewing_other = signed_in? && current_user != @user

    @current_link_text = "My Profile" if @viewing_self
    
    # @accepted_followers = @user.accepted_followers
    @accepted_friends = @user.accepted_friends.sort_by {|ff| ff.name}
    @display_user_stats = current_user.can_see_activity_of(@user)
    @reason_for_privacy = @user.name + @user.reason_for_privacy
  end
end
