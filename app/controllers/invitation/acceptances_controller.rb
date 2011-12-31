class Invitation::AcceptancesController < ApplicationController
  before_filter :find_user, :only => :update
  before_filter :verify_required_fields_present, :only => :update

  skip_before_filter :authenticate, :only => :update
  before_filter :authenticate_without_game_begun_check, :only => :update

  def update
    @user.update_password(params[:user][:password], params[:user][:password_confirmation])
    @user.update_attribute(:location_id, params[:user][:location_id])

    unless @user.accepted_invitation_at
      @user.join_game(params[:user][:phone_number], :send) 

      flash[:success] = "Welcome to the game! Players' activity is below to the left. The scoreboard is below to the right."
    end

    redirect_to "/activity"
  end

  protected

  def find_user
    @user = User.find_by_slug(params[:user_id])
  end

  def verify_required_fields_present
    location_required = @user.demo.locations.count > 0

    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]

    all_present = password.present? && password == password_confirmation && (!location_required || params[:user][:location_id].present?)

    unless all_present
      flash[:failure] = location_required ? "Please choose a password and location." : "Please choose a password."
      redirect_to :back
      return false
    end
  end
end
