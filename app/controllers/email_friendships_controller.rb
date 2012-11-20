class EmailFriendshipsController< ApplicationController

  skip_before_filter :authorize
  skip_before_filter :verify_authenticity_token

  # Not using the 7 RESTful actions because this guy is fired off from link within email

  def accept
    friendship = Friendship.find params[:id].to_i

    if EmailLink.validate_token(friendship, params[:token])
      flash[:success] = friendship.accept
    else
      flash[:failure] = 'Invalid authenticity token. Friendship operation cancelled.'
    end

    redirect_to home_url
  end
end
