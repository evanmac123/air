class AccountsController < ApplicationController
  def update
    current_user.attributes = params[:user]
    current_user.save!
    flash[:success] = "Your account settings have been updated."
    redirect_to current_user
  end
end
