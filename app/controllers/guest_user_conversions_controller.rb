class GuestUserConversionsController < ApplicationController
  include AllowGuestUsers

  def create
    unless current_user && current_user.is_guest?
      render inline: ''
      return
    end

    full_user = current_user.convert_to_full_user!(
      params[:user][:name],
      params[:user][:email],
      params[:user][:password]
    )

    if full_user
      original_guest_user = current_user
      sign_in(full_user, :remember_user)
      flash[:success] = "Account created! A confirmation email will be sent to #{full_user.email}."
      ping('User - New', {source: 'public link'}, original_guest_user)
      render_success_json
    else
      render_failure_json
    end
  end

  private

    def render_success_json
      render json: {status: 'success'}
    end

    def render_failure_json
      render json: {status: 'failure', errors: current_user.errors.messages}
    end

    def find_board_for_guest
      @demo ||= Demo.find(params[:user][:demo_id])
    end
end
