class Invitation::FriendInvitationsController < ApplicationController
  
  skip_before_filter :authenticate
  before_filter :authenticate_without_game_begun_check
  
  def create
    email_prepend = params[:email_prepend]
    unless email_prepend.nil?
      # self-inviting-domain demos
      email = email_prepend + "@" + current_user.demo.self_inviting_domains.first.domain
      user = User.new(:email => email, :demo_id => current_user.demo_id)
      add_failure "Unable to create user with email address #{email}" unless user.save
    else      
      # Preloaded demos
      user = User.find(params[:invitee_id])
      if user.nil?
        add_failure "User not found"
        redirect_to activity_path and return 
      end
    end

    
    @invitation_request = InvitationRequest.new(:email => user.email)
    
    unless @invitation_request.valid?
      add_failure "For some reason, that email address didn't work" # should never happen
      redirect_to activity_path and return
    end

    unless email_prepend.nil?
      unless @inviting_domain = @invitation_request.self_inviting_domain
        add_failure "I'm sorry, that user is not at the proper domain to receive an invitation" # should never happen
        redirect_to activity_path and return
      end
    end
    
    user.invite(current_user)
    if user.name.empty?
      add_success "You just invited #{user.email} to play H Engage"
    else
      add_success "You just invited #{user.name} to play H Engage"
    end
    redirect_to activity_path
    
  end

end
