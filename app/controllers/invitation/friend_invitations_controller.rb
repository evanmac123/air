class Invitation::FriendInvitationsController < ApplicationController
  
  skip_before_filter :authenticate
  before_filter :authenticate_without_game_begun_check
  
  def create
    users_invited = []
    # Pre-populated Domain
    if params[:invitee_ids]
      an_array = params[:invitee_ids].gsub(',', '').strip.split.uniq
      user_ids = an_array.collect do |f|
        f.to_i
      end
      user_ids.each do |i|
        user = User.find(i)
        if user.nil?
          add_failure "User #{i} not found. "
        else
          @invitation_request = InvitationRequest.new(:email => user.email)
          user.invite(current_user)
          users_invited <<  user.name          
        end        
      end
      
      unless users_invited.empty?
        sentence = create_sentence_response(users_invited)
        add_success(sentence) 
      end
      
      redirect_to activity_path and return        
    end
    
    # Self-inviting Domain
    domain = current_user.demo.self_inviting_domains.first.domain
    unless domain
      add_failure "The domain is wrong"
      redirect_to activity_path and return
    end
    hash_of_prepends = params[:email_prepends]
    existing_users = []
    if hash_of_prepends.nil?
      add_failure no_at_sign_error_message
      redirect_to activity_path and return        
    end      
    check_for_all_blank = ''
    hash_of_prepends.each_pair do |key,prepend|
      next if prepend.empty?
      check_for_all_blank += prepend
      email = prepend + "@" + domain
      users_with_email = User.where(:email => email)
      users_with_email_in_same_demo = User.where(:email => email, :demo_id => current_user.demo_id)
      
      if prepend.include? "@"
        add_failure no_at_sign_error_message
        
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
    add_failure "Please enter the first part of your friends' email address, then click 'Invite'" if check_for_all_blank.empty?
    unless existing_users.empty?
      add_failure "Thanks, but the following users are already playing the game: " + existing_users.join(', ') 
    end
    unless users_invited.empty?
      sentence = create_sentence_response(users_invited)
      add_success(sentence) 
    end
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
end
