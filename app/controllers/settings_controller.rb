class SettingsController < ApplicationController

  before_filter :authorize_without_guest_checks

  def edit
    @palette = current_user.demo.custom_color_palette
    @email = current_user.email

    uscl = UserSettingsChangeLog.where(user: current_user).first
    if uscl && uscl.email != @email
      @pending_email = uscl.email
    end
  end

  def update
    if current_user.update_attributes protected_params[:user]
      flash[:success] = "OK, your settings were updated."
    else
      flash[:failure] = current_user.errors.smarter_full_messages.join(' ')
    end

    redirect_to :back
  end

  protected

  def protected_params
    params.permit(user: [:privacy_level])
  end
end
