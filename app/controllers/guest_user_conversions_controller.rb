class GuestUserConversionsController < ApplicationController
  prepend_before_filter :allow_guest_user, :only => :create

  def create
    if current_user.is_guest?
      full_user = current_user.convert_to_full_user!(
        params[:user][:name],
        params[:user][:email],
        params[:user][:password]
      )

      sign_in full_user
      redirect_to :back
    else
      render inline: ''
    end
  end
end
