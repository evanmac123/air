class InvitationsController < ApplicationController
  skip_before_filter :authorize

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
    if (@user = @invitation_request.preexisting_user)
      if @user.claimed?
        render "duplicate_email"
      else
        @user.invite
      end
    elsif ENV['JOIN_TYPE'] == 'public'
      @user = @invitation_request.create_and_invite_user_to_public_game
    else
      @invalid_email = true
      render "invalid_email"
    end

  end

  def show
    @user = User.find_by_invitation_code(params[:id])
    # can return potential user or user
    @user = PotentialUser.search_by_invitation_code(params[:id]) unless @user

    if @user
      @referrer_id = params[:referrer_id] if params[:referrer_id] =~ /^\d+$/

      if @user.is_a? User
        @user.ping_page('invitation acceptance', 'invitation acceptance version' => "v. 6/25/14")
        email_clicked_ping(@user)
        return if redirect_if_invitation_for_accepted_user_to_new_board
        return if redirect_if_invitation_accepted_already
        log_out_if_logged_in

        #if it is not admin we are going to create and set random password for him
        unless @user.is_client_admin || @user.is_site_admin
          redirect_to generate_password_invitation_acceptance_path( user_id: @user.id, 
                                                demo_id: params[:demo_id], 
                                                invitation_code: @user.invitation_code, 
                                                referrer_id: @referrer_id)
        end
      else
        log_out_if_logged_in
        session[:potential_user_id] = @user.id
        @user.update_attribute(:game_referrer_id, @referrer_id)
        redirect_to activity_path
      end
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to "/"
    end
  end

  protected

  def redirect_if_invitation_for_accepted_user_to_new_board
    if @user.claimed? && 
      !@user.in_board?(params[:demo_id])

      @user.add_board(params[:demo_id])
      @user.move_to_new_demo params[:demo_id]
      @user.credit_game_referrer User.find(@referrer_id)
      flash[:success] = "Welcome, #{@user.name}"
      sign_in(@user)
      redirect_to activity_path
    else
      nil
    end
  end

  def redirect_if_invitation_accepted_already
    if @user.claimed?
      if current_user
        flash[:failure] = "You've already accepted your invitation to the game."
        if params[:demo_id]
          current_user.move_to_new_demo(params[:demo_id])
        end
        redirect_to activity_path
      else
        flash[:failure] = Clearance::SESSION_EXPIRED
        flash[:failure_allow_raw] = true
        redirect_to sign_in_path(demo_id: params[:demo_id])
      end

      return true
    end
  end
end
