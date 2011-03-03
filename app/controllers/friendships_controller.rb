class FriendshipsController < ApplicationController
  def create
    @user = User.find_by_slug(params[:user_id])
    current_user.friendships.create(:friend_id => @user.id)
    @user.reload

    respond_to do |format|
      format.mobile do
        @acts = @user.acts.recent(10)
        render :partial => 'create'
      end
    end
  end

  def destroy
    @user = User.find_by_slug(params[:user_id])
    current_user.friendships.where(:friend_id => @user.id).first.destroy
    @user.reload

    respond_to do |format|
      format.mobile do
        @acts = @user.acts.recent(10)
        render :partial => 'destroy'
      end
    end
  end
end
