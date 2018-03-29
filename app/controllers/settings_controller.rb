# frozen_string_literal: true

class SettingsController < UserBaseController
  include ThemingConcern
  before_action :set_theme

  def edit
    @email = current_user.email

    uscl = UserSettingsChangeLog.where(user: current_user).first
    if uscl && uscl.email != @email
      @pending_email = uscl.email
    end
  end

  def update
    if current_user.update_attributes(user_params)
      flash[:success] = "OK, your settings were updated."
    else
      flash[:failure] = current_user.errors.smarter_full_messages.join(" ")
    end

    redirect_to :back
  end

  private

    def user_params
      params.require(:user).permit(:privacy_level)
    end
end
