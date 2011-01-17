class UsersController < ApplicationController
  def show
    @user = User.find_by_slug(params[:id])
    @acts = @user.acts.recent(10)
  end
end
