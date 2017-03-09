class Invitation::FriendInvitationsController < UserBaseController
  def create
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
  end

  def invite_user_by_email invitee_email
    user = PotentialUser.where(email: invitee_email, demo: current_user.demo).first_or_create
    if user
      user.is_invited_by current_user
      @message = success_message
    else
      @message =  "Wrong email."
    end
  end

  def success_message
    "<span class='sending_success'>Invitation sent - thanks for sharing!</span>".html_safe
  end

  def no_at_sign_error_message
    %{Please enter only the part of the email address before the "@" - and remember that only colleagues in your organization can participate.}
  end
end
