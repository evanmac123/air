class Invitation::FriendInvitationsController < ApplicationController
  
  skip_before_filter :authenticate
  before_filter :authenticate_without_game_begun_check
  
  def create
    successful_invitation_count = 0

    # Pre-populated Domain
    invitee_id = params[:invitee_id]
    if invitee_id
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
        pp = current_user.demo.game_referrer_bonus
        bonus_message = pp ? "That's <span class='orange'>#{pp}</span> potential points!".html_safe : ''
        @message = "Invitation sent&#8212;#{bonus_message}<br>Search again to invite more".html_safe  
        attempted, successful = 1,0      
      end        

      record_mixpanel_ping(attempted, successful)  
      return        
    end
    users_invited = []
    
    # Self-inviting Domain or Public Join
    unless current_user.demo.is_public_game
      begin
        domain = current_user.self_inviting_domain.domain
      rescue
        domain = nil
      end
      unless domain
        add_failure "Could not find a self-inviting domain for this game that matches '#{current_user.email.email_domain}'. Please contact support@hengage.com."
        redirect_to activity_path and return
      end
    end
    
    hash_of_prepends = params[:email_prepends]
    existing_users = []
    if hash_of_prepends.nil?
      add_failure no_at_sign_error_message
      redirect_to activity_path and return        
    end      

    check_for_all_blank = ''

    User.transaction do
      hash_of_prepends.each_pair do |key,prepend|
        next if prepend.empty?
        check_for_all_blank += prepend
        email = prepend.downcase
        users_with_email = User.where(:email => email)
        users_with_email_in_same_demo = User.where(:email => email, :demo_id => current_user.demo_id)
        
        if email.is_not_email_address? 
          add_failure "#{email} is not a valid email address"
        elsif current_user.demo.valid_email_to_create_new_user(email) == false
          add_failure "#{email} is not on a self-inviting domain. Please enter work email addresses."
        elsif users_with_email.present? && users_with_email_in_same_demo.empty?
          add_failure "Thanks, but #{email} is in a different game than you."
        elsif users_with_email.empty? 
          # create a new user, then invite
          user = User.new(:email => email, :demo_id => current_user.demo_id)
          unless user.save
            add_failure "Unable to create user with email address #{email}"
          end
          @invitation_request = InvitationRequest.new(:email => user.email)
          add_failure "For some reason, the address #{email} didn't work" unless @invitation_request.valid?
          users_invited << email
          user.invite(current_user)        
        elsif User.where(:email => email).first.accepted_invitation_at 
          # user already playing, so discard
          existing_users << email 
        else  
          # user already created, but invitation not accepted, so send invitation again
          user = User.where(:email => email, :demo_id => current_user.demo_id).first
          user.invite(current_user)
          users_invited << email
        end
      end
    end

    add_failure "Please enter the first part of your friends' email address, then click 'Invite'" if check_for_all_blank.empty?
    unless existing_users.empty?
      add_failure "Thanks, but the following users are already playing the game: " + existing_users.join(', ') 
    end
    unless users_invited.empty?
      sentence = create_sentence_response(users_invited)
      add_success(sentence) 
    end

    attempted_invitation_count = hash_of_prepends.values.select(&:present?).length
    record_mixpanel_ping(users_invited.length, attempted_invitation_count)

    redirect_to activity_path 
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
    success_string += " to play H Engage. "
    unless current_user.demo.game_referrer_bonus.nil?
      success_string += "That's #{current_user.demo.game_referrer_bonus * name_array.length} potential bonus points!"
    end
    success_string
  end

  protected

  def no_at_sign_error_message
    %{Please enter only the part of the email address before the "@" - and remember that only colleagues in your organization can play.}  
  end

  def record_mixpanel_ping(successful_invitations, attempted_invitations)
    mixpanel_details = {
      :successful_invitations => successful_invitations,
      :attempted_invitations  => attempted_invitations
    }.merge(current_user.data_for_mixpanel) 

    flash[:mp_track_invited_users] = ['invited friends', mixpanel_details]
  end
end
