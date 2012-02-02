class Invitation::AcceptancesController < ApplicationController
  before_filter :find_user, :only => :update

  skip_before_filter :authenticate, :only => :update
  #before_filter :authenticate_without_game_begun_check, :only => :update

  layout "external"

  def update
    # Set this as true so presence of name is validated
    @user.trying_to_accept = true 
    @user.attributes = params[:user]
    @user.slug = params[:user][:sms_slug]
    @user.valid?
    @user.errors.add(:terms_and_conditions, "You must accept the terms and conditions") unless params[:user][:terms_and_conditions]
    @user.errors.add(:password_confirmation, "Please enter the password here too") if params[:user][:password].blank?
    
    
    # the below calls @user#save, so we don't save explicitly
    unless @user.update_password(params[:user][:password], params[:user][:password_confirmation])
      @locations = @user.demo.locations.alphabetical
      
      if @user.errors[:password] == ["doesn't match confirmation"]
        @user.errors[:password].clear
        @user.errors[:password] = "Sorry, your passwords don’t match"
      end

      if params[:user][:sms_slug].blank?  
        # make sure you don't three errors when only one is relevant
        @user.errors[:sms_slug].clear
        @user.errors[:sms_slug] = "Please choose a username"
      end
      
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

    sign_in(@user)

    redirect_to "/activity"
  end
  

  protected

  def find_user
    @user = User.find(params[:user_id])
  end
end
