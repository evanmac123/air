class FollowersController < ApplicationController
  before_filter :find_pending_friendship, :only => [:update]

  def show
    respond_to do |format|
      format.js do
        @followers = current_user.accepted_followers.most_recent.offset(params[:offset].to_i)
        @all_friend_ids = current_user.friendships.map(&:friend_id)
      end
    end
  end

  def update
    flash[:success] = case params[:disposition]
                      when 'accept'
                        @friendship.accept
                      when 'ignore'
                        @friendship.ignore
                      end

    redirect_to :back
  end

  protected

  def find_pending_friendship
    @friendship = Friendship.pending_between(current_user, :follower_id => params[:follower_id])

    unless @friendship
      if Friendship.accepted_between(current_user, :follower_id => params[:follower_id])
        flash[:failure] = "You've already accepted that person's request."
      else
        flash[:failure] = "You've already ignored that person's request."
      end

      redirect_to :back
    end
  end
end
