class GuestUserResetsController < ApplicationController
  include AllowGuestUsers

  def update
    if current_user && current_user.is_guest?
      current_user.points = 0
      current_user.tickets = 0
      current_user.get_started_lightbox_displayed = false
      current_user.save!

      current_user.acts.each(&:destroy)
      current_user.tile_completions.each(&:destroy)
      session[:display_start_over_button] = false
      session[:conversion_form_shown_already] = false
    end

    redirect_to public_activity_path(current_user.demo.public_slug)
  end

  def saw_modal
    session[:conversion_form_shown_already] = true
    render nothing: true
  end

  private

    def find_current_board
      Demo.find(params[:user][:demo_id])
    end
end
