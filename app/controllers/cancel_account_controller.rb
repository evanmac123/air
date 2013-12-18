class CancelAccountController < ApplicationController
  skip_before_filter :authorize
  before_filter :find_user

  # This is in a separate controller, rather than incorporated into
  # AccountsController, since AccountsController assumes we're logged in, and
  # it's a singular resource, so we don't have a convenient place to put a token
  # for the user.
  #
  # Please don't tell the REST police.

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
