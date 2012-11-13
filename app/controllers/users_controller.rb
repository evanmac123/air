class UsersController < Clearance::UsersController
  USER_LIMIT = 50

  def index
    @friend_ids = current_user.friend_ids
    @search_link_text = "our search bar"
    @search_string = params[:search_string]

    if @search_string
      @search_string = @search_string.downcase.strip.gsub(/\s+/, ' ')
      @other_users = User.claimed.demo_mates(current_user).alphabetical.name_like(@search_string)
      @users_cropped = USER_LIMIT if @other_users.length > USER_LIMIT
      @other_users = @other_users[0, USER_LIMIT]

      @search_link_text = "refining your search"
    end

    if invoke_tutorial
      # tutorial ping already sent, so we won't send a 'viewed page' ping
    else
      current_user.ping_page('user directory', :game => current_user.demo.name)
    end
  end

  def show
    @user = current_user.demo.users.find_by_slug(params[:id])
    @current_user = current_user
    unless @user
      render :file => "#{Rails.root}/public/404.html", :status => :not_found, :layout => false
      return
    end

    @locations = @user.demo.locations
    @acts = @user.acts.unhidden.same_demo(@user).recent(10)
    @viewing_self = signed_in? && current_user == @user
    @viewing_other = signed_in? && current_user != @user

    @current_link_text = "My Profile" if @viewing_self
    @has_friends = (@user.accepted_friends.count > 0)
    @pending_friends = @user.pending_friends
    
    @display_user_stats = current_user.can_see_activity_of(@user)
    @reason_for_privacy = @user.name + @user.reason_for_privacy
    if @pending_friends.present?
      @display_pending_friendships = true if @viewing_self || current_user.is_site_admin       
    end
    
    if invoke_tutorial
      # tutorial ping already sent, so we don't send 'viewed page' pings
    elsif @viewing_self
      current_user.ping_page 'own profile'
    elsif @viewing_other
      current_user.ping_page("profile for someone else", {:viewed_person => @user.name, :viewed_person_id => @user.id})
    end
  end
end
