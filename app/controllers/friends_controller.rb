class FriendsController < ApplicationController
  def show
    @friends = current_user.friends
    @followers = current_user.followers
  end
end
