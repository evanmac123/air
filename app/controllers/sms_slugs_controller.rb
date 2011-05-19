class SmsSlugsController < ApplicationController
  def update
    current_user.sms_slug = params[:user][:sms_slug]

    if current_user.save
      flash[:success] = "Your unique ID was changed to #{current_user.sms_slug}"
    else
      flash[:failure] = current_user.errors[:sms_slug]
    end

    redirect_to :back
  end
end
