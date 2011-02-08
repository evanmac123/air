class HomesController < ApplicationController
  def show
    @demo  = current_user.demo
    @user  = @demo.users.build
    @users = @demo.users.order('points DESC')
  end
end
