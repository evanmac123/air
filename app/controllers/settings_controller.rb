class SettingsController < ApplicationController

  before_filter :parse_date_of_birth, :only => :update
  before_filter :authorize_without_game_begun_check

  def edit
  end

  def update
    if current_user.update_attributes params[:user]
      flash[:success] = "OK, your settings were updated."
    else
      flash[:failure] = current_user.errors.smarter_full_messages.join(' ')
    end

    redirect_to :back
  end

  protected

  def parse_date_of_birth
    params[:user][:date_of_birth] = Chronic.parse(params[:user][:date_of_birth], :context => :past)
  end
end
