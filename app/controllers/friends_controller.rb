class FriendsController < ApplicationController
  def show
    @current_link_text = "Connections"

    @friends = current_user.accepted_friends

    respond_to do |format|
      format.html do
        @friends = @friends.most_recent(4)
        @all_friend_ids = current_user.accepted_friendships.map(&:friend_id)
        @accepted_followers = current_user.accepted_followers.most_recent(4)
        @pending_followers = current_user.pending_followers
      end

      format.js do
        @friends = @friends.most_recent.offset(params[:offset].to_i)
      end
    end
  end
end
