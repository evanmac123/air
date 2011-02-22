class InvitationsController < ApplicationController
  skip_before_filter :authenticate

  def show
    @user = User.find_by_invitation_code(params[:id])
    if @user 
      unless @user == current_user
        flash.now[:success] = "You're now signed in."
        sign_in(@user)
      end
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to "/"
    end
  end
end
