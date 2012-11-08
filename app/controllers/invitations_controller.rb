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
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = User.find_by_invitation_code(params[:id])
      if params[:easy_in]
        easy_in_mixpanel_ping
        @user.session_count = 2 # This makes sure invite friends modal does not pop
        @user.accepted_invitation_at = Time.now
        @user.save
        sign_in @user
        @user.create_active_tutorial_at_slide_one
        redirect_to activity_path and return
      end
    end

    referrer_id = params[:referrer_id]
    if referrer_id =~ /^\d+$/
      @user.game_referrer_id = referrer_id
    end
    if @user
      @user.ping_page('invitation acceptance')
      return if redirect_if_invitation_accepted_already
      log_out_if_logged_in
      @locations = @user.demo.locations.alphabetical
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to "/"
    end
  end

  protected
  def easy_in_mixpanel_ping
    event_name = "clicked email"
    extra = {:link => "easy in"}
    mixpanel_details = extra.merge(@user.data_for_mixpanel)
    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track_event(event_name, mixpanel_details)
  end

  def redirect_if_invitation_accepted_already
    if @user.accepted_invitation_at.present?
      if current_user
        flash[:failure] = "You've already accepted your invitation to the game."
        redirect_to activity_path
      else
        flash[:failure] = "You've already accepted your invitation to the game. Please log in if you'd like to use the site."
        redirect_to sign_in_path
      end

      return true
    end
  end
end
