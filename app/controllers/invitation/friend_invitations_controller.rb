class Invitation::FriendInvitationsController < ApplicationController
  
  skip_before_filter :authorize
  before_filter :authorize_without_guest_checks
  
  def create
    render 'shared/ajax_refresh_page' and return unless current_user
    # Pre-populated Domain
    invitee_id = params[:invitee_id]
    invitee_email = params[:invitee_email]
    if invitee_id.present?
      invite_user_by_id invitee_id        
    elsif invitee_email.present?
      invite_user_by_email invitee_email
    else
      @message = "Wrong data. Please try again"
    end
  end

  protected

  def invite_user_by_id invitee_id 
    user = User.find(invitee_id)
    if user.nil?
      @message =  "User not found."
      attempted, successful = 1,0
    elsif user.claimed?
      @message =  "Thanks, but #{user.name} is already playing. Try searching for someone else."
      attempted, successful = 1,0
    else
      user.invite(current_user)
      @message = success_message
      attempted, successful = 1,1     
    end
    record_mixpanel_ping(attempted, successful, "name", user)  
  end

  def invite_user_by_email invitee_email
    user = PotentialUser.where(email: invitee_email, demo: current_user.demo)
                        .first_or_create
    if user
      user.is_invited_by current_user
      @message = success_message
      record_mixpanel_ping(1, 1, "email", user)
    else
      @message =  "Wrong email."
      record_mixpanel_ping(0, 1, "email")
    end
  end

  def success_message
    "<span class='sending_success'>Invitation sent - thanks for sharing!</span>".html_safe
  end

  def no_at_sign_error_message
    %{Please enter only the part of the email address before the "@" - and remember that only colleagues in your organization can participate.}
  end

  def record_mixpanel_ping(successful_invitations, attempted_invitations, invited_via, user = nil)
    mixpanel_details = {
      successful_invitations: successful_invitations,
      attempted_invitations:  attempted_invitations,
      invited_via: invited_via

    } 
    ping('invited friends', mixpanel_details, current_user)

    ping('Email Sent', {email_type: "Friend Invitation"}, user) if user
  end
end
