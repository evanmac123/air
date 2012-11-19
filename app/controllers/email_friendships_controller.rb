class EmailFriendshipsController< ApplicationController

  skip_before_filter :authorize
  skip_before_filter :verify_authenticity_token

  # Not using the 7 RESTful actions because these guys are
  # fired off from links within emails => Need to be 'get'

  def accept
    valid_token? ? (flash[:success] = friendship.accept) : bad_token_message
    redirect_to home_url
  end

  def ignore
    valid_token? ? (flash[:success] = friendship.ignore) : bad_token_message
    redirect_to home_url
  end

  protected

  def friendship
    Friendship.find params[:id].to_i
  end

  def valid_token?
    EmailLink.validate_token friendship, params[:token]
  end

  def bad_token_message
    flash[:failure] = 'Invalid authenticity token. Friendship operation cancelled.'
  end
end
