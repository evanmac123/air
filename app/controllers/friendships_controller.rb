class FriendshipsController < ApplicationController
  def create
    @user = User.find_by_slug(params[:user_id])
    current_user.befriend(@user)
    @user.reload

    respond_to do |format|
      format.html {redirect_to :back}

      format.js

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
      format.html {redirect_to :back}

      format.js

      format.mobile do
        @acts = @user.acts.recent(10)
        render :partial => 'destroy'
      end
    end
  end
end
