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
    current_user.friendships.where(:friend_id => @user.id).first.destroy
    @user.reload

    respond_to do |format|
      format.html do
        redirect_to :back
        flash[:mp_track_friendship] = ["defanned"]
      end

      format.js
    end
  end
end
