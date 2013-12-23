class GuestUserResetsController < ApplicationController
  prepend_before_filter :allow_guest_user

  def update
    if current_user.is_guest?
      current_user.points = 0
      current_user.tickets = 0
      current_user.save!

      current_user.acts.each(&:destroy)
      current_user.tile_completions.each(&:destroy)
      session[:display_start_over_button] = false
    end

    redirect_to :back
  end
end
