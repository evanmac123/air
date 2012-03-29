class FriendshipsController < ApplicationController
  before_filter :game_not_closed_yet

  def create
    @user = User.find_by_slug(params[:user_id])
    new_friendship = current_user.befriend(@user)
    new_friendship.accept if @user.name == Tutorial.example_search_name
    @user.reload
    properties = params[:friend_link] == "follow_to_see_activity" ? {:friend_link => :follow_to_see_activity} : {}
    

    respond_to do |format|
      format.html do
        if new_friendship
          flash[:success] = @user.follow_requested_message
          flash[:mp_track_friendship] = ["fanned", properties]
        end
        redirect_to :back
      end

      format.js
    end
  end

  def destroy
    @friend = User.find_by_slug(params[:user_id])
    friendship = current_user.friendships.where(:friend_id => @friend.id).first
    reciprocal_friendship = @friend.friendships.where(:friend_id => current_user.id).first
    if friendship
      Friendship.transaction do
        friendship.destroy
        reciprocal_friendship.destroy if reciprocal_friendship
        flash[:success] = @friend.follow_removed_message
      end
    else
      add_success "You were not friends with #{@user.name}. No action taken"
    end
    
    respond_to do |format|
      format.html do
        redirect_to :back
        flash[:mp_track_friendship] = ["unfriended"]
      end

      format.js
    end
  end

  protected

  def game_not_closed_yet
    return unless current_user.demo.ends_at && Time.now > current_user.demo.ends_at

    flash[:failure] = "Thanks for playing! The game is now over."
    redirect_to :back
  end
end
