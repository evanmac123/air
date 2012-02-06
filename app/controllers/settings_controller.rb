class SettingsController < ApplicationController
  layout "application"

  before_filter :parse_date_of_birth, :only => :update
  skip_before_filter :authenticate
  before_filter :authenticate_without_game_begun_check

  def edit
    @locations = current_user.demo.locations.alphabetical
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
