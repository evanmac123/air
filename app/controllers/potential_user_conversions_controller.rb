class PotentialUserConversionsController < ApplicationController
  def create
    if current_user && current_user.is_a?(PotentialUser)
      full_user = current_user.convert_to_full_user! params[:potential_user_name]
      if full_user
        full_user.credit_game_referrer current_user.game_referrer
        session[:potential_user_id] = nil
        flash[:success] = "Welcome, #{full_user.name}"
        current_user.destroy
        sign_in full_user
      else
        flash[:failure] = "Wrong name!"
      end
    end
    redirect_to activity_path
  end
end
