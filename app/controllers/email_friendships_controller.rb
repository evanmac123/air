class EmailFriendshipsController< ApplicationController

  # todo What about this stuff?

  #skip_before_filter :authorize
  #skip_before_filter :force_ssl
  #skip_before_filter :verify_authenticity_token

  # Not using 7 RESTful actions because these guys are
  # fired off from links within emails => Need to be 'get'

  def accept
    flash[:success] = friendship.accept
    redirect_to home_url
  end

  def ignore
    flash[:success] = friendship.ignore
    redirect_to home_url
  end

  protected

  def friendship
    Friendship.find params[:id].to_i
  end
end
