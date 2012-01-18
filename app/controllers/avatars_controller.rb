class AvatarsController < ApplicationController
  def update
    if params[:user].blank? || params[:user][:avatar].blank?
      flash[:failure] = "Please choose a file to use for your avatar."
      flash[:mp_track_avatar] = ["changed avatar", {:success => false}]
    else
      current_user.avatar = params[:user][:avatar]
      current_user.save!
      flash[:mp_track_avatar] = ["changed avatar", {:success => true}]
    end

    redirect_to :back
  end

  def destroy
    current_user.avatar = nil
    current_user.save!
    flash[:mp_track_avatar] = ["removed avatar"]
    redirect_to :back
  end
end
