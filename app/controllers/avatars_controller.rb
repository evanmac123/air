class AvatarsController < ApplicationController
  skip_before_filter :authorize
  before_filter :authorize_without_guest_checks

  def update
    if params[:user].blank? || params[:user][:avatar].blank?
      flash[:failure] = "Please choose a file to use for your avatar."
      flash[:mp_track_avatar] = ["changed avatar", {:success => false, :reason => "no file chosen"}]
    else
      begin
        current_user.avatar = params[:user][:avatar]
        current_user.save!
        flash[:mp_track_avatar] = ["changed avatar", {:success => true}]
      rescue ActiveRecord::RecordInvalid => e
        flash[:failure] = "Sorry, I didn't understand that file you tried to upload as an image file."
        flash[:mp_track_avatar] = ["changed avatar", {:success => false, :reason => e.message, :error_class => e.class, :content_type => params[:user][:avatar].content_type, :original_filename => params[:user][:avatar].original_filename}]
      end
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
