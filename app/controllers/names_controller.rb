class NamesController < ApplicationController
  def update
    current_user.name = params[:user][:name]

    if current_user.save
      flash[:success] = "OK, from now on we'll call you \"#{current_user.name}.\""
    else
      flash[:failure] = "Sorry, you can't change your name to something blank."
    end

    redirect_to :back
  end
end
