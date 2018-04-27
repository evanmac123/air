# frozen_string_literal: true

class InvitationsController < ApplicationController
  include TileEmailTrackingConcern
  include ActsHelper

  layout "external"

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
    @user = find_user
    set_tile_id_for_open_graph
    set_open_graph_tile_for_admin
    if @user
      @referrer = get_referrer
      @demo = Demo.find_by(id: params[:demo_id])
      schedule_pings
      process_invitation
    else
      require_login
    end
  end

  private

    def find_user
      User.find_by(invitation_code: params[:id]) || PotentialUser.search_by_invitation_code(params[:id])
    end

    def get_referrer
      if params[:referrer_id]
        User.find(params[:referrer_id])
      else
        @user.game_referrer
      end
    end

    def schedule_pings
      track_tile_email_logins(user: @user)
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
        true
      end
    end

    def invitation_to_board_already_accepted
      if @user.claimed?
        if user_can_login_to_already_accepted_board? && @demo.present?
          sign_in(@user, :remember_me)
          current_user.move_to_new_demo(@demo)
          redirect_to redirect_path
        else
          require_login
        end
      end
    end

    def user_can_login_to_already_accepted_board?
      if current_user == @user || !@user.is_client_admin_in_any_board
        true
      elsif params[:new_lead] && @demo.free?
        true
      else
        false
      end
    end

    def accept_unclaimed_user
      if @user.unclaimed?
        unless require_password_creation
          redirect_to generate_password_invitation_acceptance_path(
            user_id: @user.id,
            demo_id: @demo.try(:id),
            invitation_code: @user.invitation_code,
            referrer_id: @referrer.try(:id)
          )
        else
          render "show"
        end
      end
    end

    def require_password_creation
      return false if params[:new_lead]
      @user.is_client_admin || @user.is_site_admin
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

    def redirect_path
      if current_user.is_client_admin
        explore_path
      else
        activity_path
      end
    end
end
