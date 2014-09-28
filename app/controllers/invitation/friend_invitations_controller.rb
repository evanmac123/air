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
=begin
  def create_sentence_response(name_array)
    name_array.sort!
    success_string = "You just invited "
    which_time = 1
    name_array.each do |name|
      if which_time == 1
        success_string += name
      elsif which_time == 2 && name_array.length == 2
        success_string += " and #{name}"
      elsif which_time == name_array.length
        success_string += ", and " + name
      else
        success_string += ", " + name
      end
      which_time += 1
    end
    success_string += " to H.Engage. "
    unless current_user.demo.game_referrer_bonus.nil?
      success_string += "That's #{current_user.demo.game_referrer_bonus * name_array.length} potential bonus points!"
    end
    success_string
  end
=end
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
    if invitee_email.is_not_email_address?
      @message =  "Wrong email."
    else
      user = User.where(email: invitee_email).first
      if user 
        user.invite(current_user, demo_id: current_user.demo.id)
        @message = success_message
      else
        user = PotentialUser
                .where(email: invitee_email, demo: current_user.demo)
                .first_or_create
        user.is_invited_by current_user
        @message = success_message
      end
      record_mixpanel_ping(1, 1, "email", user)
    end
  end

  def success_message
    "<span class='sending_success'>Invitation sent - thanks for sharing!</span>".html_safe
  end

  def no_at_sign_error_message
    %{Please enter only the part of the email address before the "@" - and remember that only colleagues in your organization can participate.}
  end

  def record_mixpanel_ping(successful_invitations, attempted_invitations, invited_via, user)
    mixpanel_details = {
      successful_invitations: successful_invitations,
      attempted_invitations:  attempted_invitations,
      invited_via: invited_via

    } 
    ping('invited friends', mixpanel_details, current_user)

    ping('Email Sent', {email_type: "Friend Invitation"}, user) if user
  end
end
