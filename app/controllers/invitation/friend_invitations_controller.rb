class Invitation::FriendInvitationsController < ApplicationController
  
  
  def create
    user = User.find(params[:invitee_id])
    
    if user.nil?
      add_failure "User not found"
      redirect_to activity_path and return 
    end
    
    @invitation_request = InvitationRequest.new(:email => user.email)
    
    unless @invitation_request.valid?
      add_failure "For some reason, that email address didn't work" # should never happen
      redirect_to activity_path and return
    end

    unless @inviting_domain = @invitation_request.self_inviting_domain
      add_failure "I'm sorry, that user is not at the proper domain to receive an invitation" # should never happen
      redirect_to activity_path and return
    end
      
    user.invite(current_user)

    add_success "You just invited #{user.name} to play H Engage"
    redirect_to activity_path
    
  end

end
