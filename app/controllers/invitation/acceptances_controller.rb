# encoding: utf-8

class Invitation::AcceptancesController < ApplicationController
  before_filter :find_user, :only => :update

  skip_before_filter :authorize, :only => :update
  #before_filter :authenticate_without_game_begun_check, :only => :update

  layout "external"

  def update
    # Set this as true so presence of name is validated
    @user.trying_to_accept = true
 
    # Unless the user was invited by SMS, their phone number (if any) needs to
    # be validated before use. But in case there are errors and we have to re-
    # render the form, remember the original phone number entered so we can 
    # stick it back in.
    entered_phone_number = params[:user][:new_phone_number]
    unless @user.invitation_requested_via_sms?
      params[:user][:new_phone_number] = PhoneNumber.normalize(entered_phone_number)
      params[:user].delete(:phone_number)
    end
    @user.attributes = params[:user]
    
    @user.slug = params[:user][:sms_slug]
    @user.valid?
    @user.errors.add(:terms_and_conditions, "You must accept the terms and conditions") unless params[:user][:terms_and_conditions]
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]
    if password.blank?
      @user.errors.add(:password, "Please choose a password") 
      @user.errors.add(:password_confirmation, "Please enter the password here too") 
    end
    
    if params[:user][:sms_slug].blank?  
      # make sure you don't three errors when only one is relevant
      @user.errors[:sms_slug].clear
      @user.errors[:sms_slug] = "Please choose a username"
    end
    
    unless password == password_confirmation
      @user.errors[:password] = User.passwords_dont_match_error_message
    end
    
    # the below calls @user#save, so we don't save explicitly
    
    if @user.errors.present?
      @html_body_controller_name = "invitations"
      @html_body_action_name = "show"
      render "/invitations/show" and return
    else
      unless @user.update_password(password)
        @user.phone_number = entered_phone_number
        @locations = @user.demo.locations.alphabetical
      end
    end
    
    unless @user.accepted_invitation_at
      @user.join_game(params[:user][:phone_number], :send) 
      @user.credit_game_referrer(User.find(@user.game_referrer_id)) unless @user.game_referrer_id.nil?
    end

    sign_in(@user)

    if @user.invitation_requested_via_sms? || @user.new_phone_number.blank?
      redirect_to activity_path
    else
      @user.generate_short_numerical_validation_token
      @user.send_new_phone_validation_token
      redirect_to phone_interstitial_verification_path
    end
  end
  


  protected

  def find_user
    @user = User.find(params[:user_id])
  end
end
