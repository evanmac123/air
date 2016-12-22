class AvatarsController < UserBaseController
  def update
    if params[:user].blank? || params[:user][:avatar].blank?
      flash[:failure] = "Please choose a file to use for your avatar."
    else
      begin
        current_user.avatar = params[:user][:avatar]
        current_user.save!
      rescue ActiveRecord::RecordInvalid
        flash[:failure] = "Sorry that doesn't look like an image file. Please use a file with the extension .jpg, .jpeg, .gif, .bmp or .png."
      end
    end

    redirect_to :back
  end

  def destroy
    current_user.avatar = nil
    current_user.save!
    redirect_to :back
  end
end
