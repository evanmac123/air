class FriendshipsController < ApplicationController
  skip_before_filter :authorize, only: :accept

  def create
    mixpanel_properties = {:channel => :web}
    if params[:friend_link] == "follow_to_see_activity" 
      mixpanel_properties[:friend_link] = :follow_to_see_activity
    end

    @user = User.find_by_slug(params[:user_id])
    new_friendship = current_user.befriend(@user, mixpanel_properties)
    new_friendship.accept if new_friendship && (@user.name == Tutorial.example_search_name)
    @user.reload

    respond_to do |format|
      format.html do
        if new_friendship
          flash[:success] = @user.follow_requested_message
        end
        redirect_to :back
      end

      format.js
    end
  end
  
  def update
    @user = User.find_by_slug(params[:user_id])
    friendship = Friendship.where(:user_id => @user.id, :friend_id => current_user.id).first
    if friendship && friendship.accept
      add_success "You are now connected to #{@user.name}"
    end
    redirect_to :back
  end

  def destroy
    @friend = User.find_by_slug(params[:user_id])
    friendship = current_user.friendships.where(:friend_id => @friend.id).first
    reciprocal_friendship = @friend.friendships.where(:friend_id => current_user.id).first
    if friendship || reciprocal_friendship
      Friendship.transaction do
        friendship.destroy if friendship
        reciprocal_friendship.destroy if reciprocal_friendship
        if friendship && friendship.state == Friendship::State::ACCEPTED
          flash[:success] = @friend.follow_removed_message
        else
          flash[:success] = "Connection request canceled"
        end
      end
    else
      add_success "You were not connected to #{@friend.name}. No action taken"
    end
    
    respond_to do |format|
      format.html do
        redirect_to :back
        flash[:mp_track_friendship] = ["unfriended"]
      end

      format.js
    end
  end

  # This action is accessed from a link within an email
  def accept
    friendship = Friendship.find params[:friendship_id].to_i

    if EmailLink.validate_token(friendship, params[:token])
      sign_in(friendship.friend) unless current_user || current_user == friendship.friend
      add_success(friendship.accept)
    else
      add_failure('Invalid authenticity token. Connection operation cancelled.')
    end
    redirect_to activity_url
  end
end
