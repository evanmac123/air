class Invitation::ResendsController < ApplicationController
  layout "application"

  skip_before_filter :authenticate

  def new
  end

  def create
    user = User.where(:email => params[:email].downcase, :invited => true).first

    if user
      if user.accepted_invitation_at.nil?
        user.invite
        flash[:success] = "We've resent your invitation to #{user.email}. If you haven't received it within a few minutes, please try again, or email support@hengage.com for help."
      else
        flash[:notice] = "It looks like you've already joined the game. You can log in <a href=\"#{new_session_path}\">here</a>, or if you've forgotten your password, you can reset it <a href=\"#{new_password_path}\">here</a>."
      end
    else
      flash[:notice] = "It looks like you haven't been invited yet. You can request an invitation <a href=\"#{new_invitation_path}\">here</a>, or contact support@hengage.com for help."     
    end

    redirect_to :back
  end
end
