class AvatarsController < ApplicationController
  def update
    if params[:user].blank? || params[:user][:avatar].blank?
      flash[:failure] = "Please choose a file to use for your avatar."
    else
      current_user.avatar = params[:user][:avatar]
      current_user.save!
    end

    redirect_to user_path(current_user)
  end

  def destroy
    current_user.avatar = nil
    current_user.save!
    redirect_to user_path(current_user)
  end
end
