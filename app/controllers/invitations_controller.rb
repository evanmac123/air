class InvitationsController < ApplicationController
  layout 'external'

  def new
    @invitation_request = InvitationRequest.new
  end

  def create
    @invitation_request = InvitationRequest.new(params[:invitation_request])

    unless @invitation_request.valid?
      render action: :new
      return
    end

    if (@user = @invitation_request.preexisting_user)
      if @user.claimed?
        render "duplicate_email"
      else
        @user.invite
      end
    else
      @invalid_email = true
      render "invalid_email"
    end

  end

  def show
    @user = User.find_by_invitation_code(params[:id])
    @user = PotentialUser.search_by_invitation_code(params[:id]) unless @user

    if @user
      @referrer = get_referrer
      @demo = Demo.find_by_id(params[:demo_id])
      send_pings
      process_invitation
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to root_path
    end
  end

  private

    def get_referrer
      if params[:referrer_id]
        User.find(params[:referrer_id])
      else
        @user.game_referrer
      end
    end

    def send_pings
      set_invitation_email_type_for_ping
      @user.ping_page('invitation acceptance')
      email_clicked_ping(@user)
      record_mixpanel_ping @user
    end

    def process_invitation
      if @user.is_a?(User)
        process_user_invitation
      else
        process_potential_user_invitation
      end
    end

    def process_user_invitation
      return if invitation_for_user_to_other_board
      return if invitation_to_board_already_accepted
      accept_unclaimed_user
    end

    def invitation_for_user_to_other_board
      if @demo.present? && !@user.in_board?(@demo)
        accept_unclaimed_user
        accept_claimed_user_to_new_board
        return true
      end
    end

    def invitation_to_board_already_accepted
      if @user.claimed?
        if current_user
          if @demo.present? && current_user.in_board?(@demo)
            current_user.move_to_new_demo(@demo)
          end
          redirect_to activity_path
        else
          require_login
        end
      end
    end

    def accept_unclaimed_user
      if @user.unclaimed?
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

    def accept_claimed_user_to_new_board
      if @user.claimed?
        if @demo.is_public?
          @user.add_board @demo
          @user.move_to_new_demo @demo
          @user.credit_game_referrer(@referrer) if @referrer.present?
          flash[:success] = "Welcome, #{@user.name}"
        else
          flash[:failure] = "Access denied to #{@demo.name}"
        end

        sign_in(@user, :remember_me)
        redirect_to activity_path
      end
    end

    def process_potential_user_invitation
      sign_out
      session[:potential_user_id] = @user.id
      @user.update_attribute :game_referrer_id, @referrer.try(:id)
      redirect_to activity_path
    end

    def record_mixpanel_ping user
      if params[:referrer_id].present?
        ping('User - New', {source: "User - Friend Invitation"}, user)
      end
    end

    def set_invitation_email_type_for_ping
      invitation_email_type = if params[:email_type].present? # digest or follow up
        if params[:email_type] == "digest_old_v" || params[:email_type] == "digest_new_v"
          "Digest email"
        elsif params[:email_type] == "follow_old_v" || params[:email_type] == "follow_new_v"
          "Follow-up"
        end
      elsif params[:referrer_id].present? # friend invitation
        "Friend Invitation"
      else # just invitation
        "Invitation email"
      end
      session[:invitation_email_type] = invitation_email_type
    end
end
