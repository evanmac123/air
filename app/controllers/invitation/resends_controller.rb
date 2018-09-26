# frozen_string_literal: true

class Invitation::ResendsController < ApplicationController
  layout "external"

  def new
  end

  def create
    user = User.where(email: params[:email].downcase, invited: true).first

    if user
      if user.accepted_invitation_at.nil?
        user.invite
        flash[:success] = %{We've resent your invitation to #{user.email}. If you haven't received it within a few minutes, please try again, or email <a href="mailto:support@airbo.com">support@airbo.com</a> for help.}
      else
        flash[:failure] = "It looks like you've already joined the game. You can log in <a href=\"#{root_path(sign_in: true)}\">here</a>, or if you've forgotten your password, you can reset it <a href=\"#{new_password_path}\">here</a>."
      end
    else
      flash[:failure] = %{It looks like you haven't been invited yet. You can request an invitation <a href="#{new_invitation_path}">here</a>, or contact <a href="mailto:support@airbo.com">support@airbo.com</a> for help."}
    end

    redirect_to :back
  end
end
