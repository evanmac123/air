class NamesController < ApplicationController
  def update
    current_user.name = params[:user][:name]

    if current_user.save
      flash[:success] = "OK, from now on we'll call you \"#{current_user.name}.\""
      flash[:mp_track_username] = ["changed username", {:success => true}]
    else
      flash[:failure] = "Sorry, you can't change your name to something blank."
      flash[:mp_track_username] = ["changed username", {:success => false}]
    end

    redirect_to :back
  end
end
