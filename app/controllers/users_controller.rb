class UsersController < UserBaseController
  prepend_before_action :authenticate

  include ActsHelper

  USER_LIMIT = 50
  MINIMUM_SEARCH_STRING_LENGTH = 3

  def index
    return not_found if current_user.demo.hide_social
    @palette = current_user.demo.custom_color_palette
    @friend_ids = current_user.friend_ids
    @search_link_text = "our search bar"
    @search_string = params[:search_string]

    if @search_string
      @search_string = @search_string.downcase.strip.gsub(/\s+/, ' ')
      @other_users = current_user.demo.claimed_users(excluded_uids: [current_user.id]).alphabetical.name_like(@search_string)
      @users_cropped = USER_LIMIT if @other_users.length > USER_LIMIT
      @other_users = @other_users[0, USER_LIMIT]

      @search_link_text = "refining your search"
    end
  end

  def show
    return not_found if current_board.hide_social && params[:id] != current_user.slug

    @user = current_board.users.find_by_slug(params[:id])
    return not_found unless @user

    @palette = current_board.custom_color_palette

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
