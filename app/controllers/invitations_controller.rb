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
      @referrer = User.find(params[:referrer_id]) if params[:referrer_id] =~ /^\d+$/
      @demo = Demo.find(params[:demo_id]) if params[:demo_id] =~ /^\d+$/

      if @user.is_a? User
        process_user_invitation
      else
        process_potential_user_invitation
      end
      record_mixpanel_ping @user
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to "/"
    end
  end

  protected

  def process_user_invitation
    @user.ping_page('invitation acceptance', 'invitation acceptance version' => "v. 6/25/14")
    email_clicked_ping(@user)
    return if invitation_for_user_to_other_board
    return if invitation_to_board_already_accepted
    accept_unclaimed_user
  end

  def invitation_to_board_already_accepted
    if @user.claimed?
      if current_user && current_user == @user
        flash[:failure] = "You've already accepted your invitation to the game."
        if @demo.present? && @user.in_board?(@demo)
          current_user.move_to_new_demo(@demo)
        end
        redirect_to activity_path(params_with_source)
      else
        flash[:failure] = Clearance::SESSION_EXPIRED
        flash[:failure_allow_raw] = true
        redirect_to sign_in_path demo_id: @demo.try(:id)
      end
    end
  end

  def invitation_for_user_to_other_board
    if @demo.present? && !@user.in_board?(@demo)
      accept_unclaimed_user
      accept_claimed_user_to_new_board
      true
    end
  end

  def accept_claimed_user_to_new_board
    if @user.claimed? 
      if @demo.is_public?
        @user.add_board @demo
        @user.move_to_new_demo @demo
        @user.credit_game_referrer(@referrer) if @referrer.present?
        flash[:success] = "Welcome, #{@user.name}"
        sign_in(@user)
        redirect_to activity_path(params_with_source)
      else
        sign_in(@user)
        flash[:failure] = "Access denied to #{@demo.name}"
        redirect_to activity_path(params_with_source)
      end
=begin 
      flash[:failure] = "You've already accepted your invitation to the game."
      if @demo.present? && @user.in_board?(@demo)
        @user.move_to_new_demo(@demo)
      end
      sign_in @user
      redirect_to activity_path(params_with_source)
=end
    end
  end

  def accept_unclaimed_user
    if @user.unclaimed?
      log_out_if_logged_in
      
      unless @user.is_client_admin || @user.is_site_admin
        redirect_to generate_password_invitation_acceptance_path( 
          user_id: @user.id, 
          demo_id: @demo.try(:id), 
          invitation_code: @user.invitation_code, 
          referrer_id: @referrer.try(:id)
        )
      else
        render 'show'
      end
    end
  end 

  def process_potential_user_invitation
    log_out_if_logged_in
    session[:potential_user_id] = @user.id
    @user.update_attribute :game_referrer_id, @referrer.try(:id)
    redirect_to activity_path(params_with_source)
  end

  def record_mixpanel_ping user
    user_type = user.is_a?(User) ? "Ordinary User" : "Potential User"
    ping('User - New', {source: "User - Friend Invitation", user_type: user_type}, current_user)
  end

  def params_with_source
    invitation_email_type = if params[:email_type].present? # then digest or follow up
      if params[:email_type] == "digest_old_v" || params[:email_type] == "digest_new_v"
        "Digest email"
      elsif params[:email_type] == "follow_old_v" || params[:email_type] == "follow_new_v"
        "Follow-up"
      end
    elsif params[:referrer_id].present? # then friend invitation
      "Friend Invitation"
    else # then just invitation
      "Invitation email"
    end
    {invitation_email_type: invitation_email_type}
  end
end
