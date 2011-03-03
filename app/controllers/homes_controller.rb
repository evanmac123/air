class HomesController < ApplicationController
  def show
    redirect_to activity_path
    #@demo  = current_user.demo
    #@user  = @demo.users.build
    ## TODO: the next line is ugly, wrote it in a big hurry
    #@users = @demo.users.order('points DESC')
  end
end
