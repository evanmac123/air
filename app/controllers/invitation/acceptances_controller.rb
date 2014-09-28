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
      @user.add_board demo
      @user.move_to_new_demo demo
    end
    
    sign_in(@user)
    flash[:success] = "Welcome, #{@user.first_name}!"
    redirect_to activity_path
  end
  #this is called to create not admin user by setting random password for him
  def generate_password
    params[:user] = @user.attributes
    params[:user][:password] = SecureRandom.hex(8)
    update
  end

  protected

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
