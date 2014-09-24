class Invitation::FriendInvitationsController < ApplicationController
  
  skip_before_filter :authorize
  before_filter :authorize_without_guest_checks
  
  def create
    render 'shared/ajax_refresh_page' and return unless current_user     
    successful_invitation_count = 0

    # Pre-populated Domain
    invitee_id = params[:invitee_id]
    invitee_email = params[:invitee_email]
    if invitee_id.present?
      user = User.find(invitee_id)
      if user.nil?
        @message =  "User #{i} not found. "
        attempted, successful = 1,0
      elsif user.claimed?
        @message =  "Thanks, but #{user.name} is already playing. Try searching for someone else."
        attempted, successful = 1,0
      else
        @invitation_request = InvitationRequest.new(:email => user.email)
        user.invite(current_user)
        demo_name = current_user.demo.name
        @message = success_message
        attempted, successful = 1,0      
      end
      record_mixpanel_ping(attempted, successful)  
      return        
    elsif invitee_email.present?
      if invitee_email.is_not_email_address?
        @message =  "Wrong email."
      else
        user = User.where(email: invitee_email).first
        if user 
          user.invite(current_user, demo_id: current_user.demo.id)
          @message = success_message
          return
        end
        potential_user = PotentialUser
                          .where(email: invitee_email, demo: current_user.demo)
                          .first_or_create
        potential_user.is_invited_by current_user
        @message = success_message
      end
    end
  end

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

  protected

  def success_message
    "<span class='sending_success'>invitation sent - thanks for sharing</span>".html_safe
  end

  def no_at_sign_error_message
    %{Please enter only the part of the email address before the "@" - and remember that only colleagues in your organization can participate.}
  end

  def record_mixpanel_ping(successful_invitations, attempted_invitations)
    mixpanel_details = {
      :successful_invitations => successful_invitations,
      :attempted_invitations  => attempted_invitations
    }.merge(current_user.data_for_mixpanel) 

    ping('invited friends', mixpanel_details, current_user)
  end
end
