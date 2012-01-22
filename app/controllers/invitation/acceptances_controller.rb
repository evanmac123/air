class Invitation::AcceptancesController < ApplicationController
  before_filter :find_user, :only => :update

  skip_before_filter :authenticate, :only => :update
  before_filter :authenticate_without_game_begun_check, :only => :update

  layout "external"

  def update
    # Set this as true so presence of name is validated
    @user.trying_to_accept = true 

    @user.attributes = params[:user]
    @user.slug = params[:user][:sms_slug]
    # the below calls @user#save, so we don't save explicitly
    unless @user.update_password(params[:user][:password], params[:user][:password_confirmation])
      @locations = @user.demo.locations.alphabetical
      render "/invitations/show"
      return
    end

    unless @user.accepted_invitation_at
      @user.join_game(params[:user][:phone_number], :send) 
      flash[:success] = "Welcome to the game! Players' activity is below to the left. The scoreboard is below to the right."
    end
    
    unless @user.game_referrer_id.nil?
      SpecialCommand.credit_game_referrer(@user, User.find(@user.game_referrer_id))
    end

    redirect_to "/activity"
  end
  

  protected

  def find_user
    @user = User.find(params[:user_id])
  end
end
