class FriendshipsController < ApplicationController
  def create
    @user = User.find_by_slug(params[:user_id])
    current_user.friendships.create(:friend_id => @user.id)
    @user.reload
  end

  def destroy
    @user = User.find_by_slug(params[:user_id])
    current_user.friendships.where(:friend_id => @user.id).first.destroy
    @user.reload
  end
end
