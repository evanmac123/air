class CancelAccountController < ApplicationController
  before_action :find_user

  layout "external"

  def show
  end

  def destroy
    @user.destroy
    flash[:success] = "OK, you've cancelled that account."
    redirect_to sign_in_path
  end

  protected

  def find_user
    @user = User.find_by_cancel_account_token(params[:id])
  end
end
