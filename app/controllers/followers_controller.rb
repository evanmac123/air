class FollowersController < ApplicationController
  def show
    respond_to do |format|
      format.js do
        @followers = current_user.accepted_followers.most_recent.offset(params[:offset].to_i)
        @all_friend_ids = current_user.friendships.map(&:friend_id)
      end
    end
  end

  def update
    friendship = Friendship.pending_between(current_user, :follower_id => params[:follower_id])

    flash[:success] = case params[:disposition]
                      when 'accept'
                        friendship.accept
                      when 'ignore'
                        friendship.ignore
                      end

    redirect_to :back
  end
end
