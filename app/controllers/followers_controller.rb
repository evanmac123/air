class FollowersController < ApplicationController
  def show
    respond_to do |format|
      format.js do
        @followers = current_user.followers.most_recent.offset(params[:offset].to_i)
        @all_friend_ids = current_user.friendships.map(&:friend_id)
      end
    end
  end
end
