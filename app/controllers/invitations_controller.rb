class InvitationsController < ApplicationController
  def show
    @user = User.find_by_invitation_code(params[:id])
    sign_in(@user)
  end
end
