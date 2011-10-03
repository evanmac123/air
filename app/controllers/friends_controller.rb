class FriendsController < ApplicationController
  def show
    @new_appearance = true

    @friends = current_user.friends

    respond_to do |format|
      format.html do
        @friends = @friends.most_recent(4)
        @all_friend_ids = current_user.friendships.map(&:friend_id)
        @followers = current_user.followers.most_recent(4)
      end

      format.js do
        @friends = @friends.most_recent.offset(params[:offset].to_i)
      end
    end
  end
end
