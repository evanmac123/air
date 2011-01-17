class InvitationsController < ApplicationController
  def show
    @user = User.find_by_invitation_code(params[:id])
    if @user
      sign_in(@user)
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to "/"
    end
  end
end
