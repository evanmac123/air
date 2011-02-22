class PhonesController < ApplicationController
  before_filter :verify_password_chosen, :only => :create

  def create
    @user = User.find_by_slug(params[:user_id])
    @user.update_password(params[:phone][:user][:password], params[:phone][:user][:password_confirmation])
    @user.join_game(params[:phone][:number])

    flash[:success] = "Welcome to the game! Players' activity is below to the left. The basic rules are below to the right."
    redirect_to "/activity"
  end

  private

  def verify_password_chosen
    password = params[:phone][:user][:password]
    password_confirmation = params[:phone][:user][:password_confirmation]
    unless password.present? && password == password_confirmation
      flash[:failure] = "Please choose a password."
      redirect_to :back
      return false
    end
  end
end
