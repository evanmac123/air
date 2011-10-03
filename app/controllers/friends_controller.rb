class FriendsController < ApplicationController
  def show
    @new_appearance = true

    @friends = current_user.friends
    @followers = current_user.followers
  end
end
