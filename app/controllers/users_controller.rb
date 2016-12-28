class UsersController < UserBaseController
  prepend_before_filter :authenticate

  USER_LIMIT = 50
  MINIMUM_SEARCH_STRING_LENGTH = 3

  def index
    @palette = current_user.demo.custom_color_palette
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

    current_user.ping_page('user directory', :game => current_user.demo.name)
  end

  def show
    demo = current_user.demo

    @user = demo.users.find_by_slug(params[:id])
    @palette = demo.custom_color_palette

    unless @user
      not_found
      return
    end

    @acts = @user.acts.for_profile(current_user)
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

    if @viewing_self
      current_user.ping_page 'own profile'
    elsif @viewing_other
      current_user.ping_page("profile for someone else", {:viewed_person => @user.name, :viewed_person_id => @user.id})
    end
  end

  private

    def authenticate
      return true if authenticate_by_token
    end

    def authenticate_by_token
      if params[:token].present? &&
        (user = User.find(params[:user_id])) &&
        EmailLink.validate_token(user, params[:token])

        sign_in(user)
        redirect_to user_url(params[:id])
      end
    end
end
