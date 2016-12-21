class UserIntrosController < ApplicationController
  prepend_before_filter :allow_guest_user

  def update
    intro = current_user.intros
    intro[params[:intro]]=true
    if intro.save
      head :ok
    else
      head :unprocessable_entity, intro.errors.msg
    end
  end
end
