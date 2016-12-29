class UserIntrosController < ApplicationController
  # TODO: Find better pattern for this as it pertains to Guest Users. Currently, there are no intros for Guest Users, so we could just inherit from UserBaseController and let normal auth do it's thing, but legacy tests have Guest Users with intros.  Either way, this is fine for now, but we should really rewrite the way we handle intros to use Redis.
  
  include AllowGuestUsersConcern

  def update
    intro = current_user.intros
    intro[params[:intro]] = true
    if intro.save
      head :ok
    else
      head :unprocessable_entity, intro.errors.msg
    end
  end

  private

    def find_board_for_guest
      nil
    end
end
