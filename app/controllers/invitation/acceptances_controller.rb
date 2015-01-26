# encoding: utf-8

class Invitation::AcceptancesController < ApplicationController
  before_filter :find_user, :only => [:update, :generate_password]

  skip_before_filter :authorize, :only => [:update, :generate_password]

  layout "external"

  def update
    # Set this as true so presence of name is validated
    @user.attributes = params[:user]

    @user.password = @user.password_confirmation = params[:user][:password]
    @user.invitation_code = params[:invitation_code] if params[:invitation_code].present?
    
    referrer_id = params[:referrer_id]
    if referrer_id =~ /^\d+$/
      @user.game_referrer_id = referrer_id
    end
    add_user_errors
    
    if @user.errors.present?
      @html_body_controller_name = "invitations"
      @html_body_action_name = "show"
      render "/invitations/show" and return
    end
    
    unless @user.accepted_invitation_at
      @user.join_game(:silent) 
      @user.credit_game_referrer @user.game_referrer_id
    end

    @user.save!

    demo = Demo.where(id: params[:demo_id]).first
    if demo
      add_user_to_board_if_allowed(demo)
    end
   
    sign_in(@user, params[:remember_me])
    flash[:success] = "Welcome, #{@user.first_name}!"
    if @user.is_client_admin || @user.is_site_admin
      redirect_to client_admin_explore_path
    else
      redirect_to activity_path
    end
  end

  #this is called to create not admin user by setting random password for him
  def generate_password
    params[:user] = @user.attributes
    params[:user][:password] = SecureRandom.hex(8)
    params[:remember_me] = "1"
    update
  end

  protected

  def add_user_to_board_if_allowed(board)
    return unless (invitation_code = @user.invitation_code)
    
    if (potential_user = PotentialUser.find_by_invitation_code(invitation_code))
      add_user_to_board_and_move(PotentialUser.demo)
    elsif (user = User.find_by_invitation_code(invitation_code))
      add_user_to_board_and_move(board) if user.in_board?(board.id) || board.is_public?
    end
  end

  def add_user_to_board_and_move(board)
    @user.add_board(board)
    @user.move_to_new_demo(board)
  end

  def find_user
    @user = User.where(id: params[:user_id], invitation_code: params[:invitation_code]).first
  end

  def add_user_errors
    @user.valid?
    if params[:user][:password].blank?
      @user.errors.add(:password, "Please choose a password") 
    end
  end
end
