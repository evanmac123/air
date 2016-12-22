class PotentialUserConversionsController < ApplicationController
  def create
    @potential_user = PotentialUser.find_by_id(session[:potential_user_id])

    if potential_user
      full_user = potential_user.convert_to_full_user!(params[:potential_user_name])
      if full_user
        full_user.credit_game_referrer(potential_user.game_referrer)
        session[:potential_user_id] = nil
        flash[:success] = "Welcome, #{full_user.name}"
        sign_in full_user
      else
        flash[:failure] = "Wrong name!"
      end
    end
    redirect_to activity_path
  end
end
