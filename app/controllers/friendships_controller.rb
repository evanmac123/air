class FriendshipsController < ApplicationController
  def create
    @user = User.find_by_slug(params[:user_id])
    new_friendship = current_user.befriend(@user)
    @user.reload

    respond_to do |format|
      format.html do
        if new_friendship
          flash[:success] = @user.follow_requested_message
          flash[:mp_track_friendship] = ["fanned"]
        end
        redirect_to :back
      end

      format.js
    end
  end

  def destroy
    @user = User.find_by_slug(params[:user_id])
    friendship = current_user.friendships.where(:friend_id => @user.id).first
    pending_friendship = current_user.friendships.where(:friend_id => @user.id).first
    if friendship
      friendship.destroy
      flash[:success] = @user.follow_removed_message
    else
      add_success "You were not following #{@user.name}. No action taken"
    end
    
    respond_to do |format|
      format.html do
        redirect_to :back
        flash[:mp_track_friendship] = ["defanned"]
      end

      format.js
    end
  end
end
