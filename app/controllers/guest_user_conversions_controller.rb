class GuestUserConversionsController < ApplicationController
  prepend_before_filter :allow_guest_user, :only => :create

  def create
    unless current_user.is_guest?
      render inline: ''
      return
    end

    full_user = current_user.convert_to_full_user!(
      params[:user][:name],
      params[:user][:email],
      params[:user][:password]
    )

    if full_user
      sign_in full_user
      render_success_json
    else
      render_failure_json
    end
  end

  protected

  def render_success_json
    render json: {status: 'success'}
  end

  def render_failure_json
    render json: {status: 'failure', errors: current_user.errors.messages}
  end
end
