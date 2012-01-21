class InvitationsController < ApplicationController
  skip_before_filter :authenticate

  layout 'external'

  def new
    @invitation_request = InvitationRequest.new
  end

  def create
    @invitation_request = InvitationRequest.new(params[:invitation_request])
    unless @invitation_request.valid?
      render :action => :new
      return
    end

    unless @inviting_domain = @invitation_request.self_inviting_domain
      render "invalid_inviting_domain"
      return
    end

    if @invitation_request.duplicate_email?
      render "duplicate_email"
      return
    end
    @user = @invitation_request.create_and_invite_user
  end

  def show
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = User.find_by_invitation_code(params[:id])
    end

    referrer_id = params[:referrer_id]
    if referrer_id =~ /^\d+$/
      @user.game_referrer_id = referrer_id
    end

    if @user
      unless @user == current_user
        flash.now[:success] = "You're now signed in."
        sign_in(@user)
      end

      @locations = @user.demo.locations.alphabetical
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to "/"
    end
  end
end
