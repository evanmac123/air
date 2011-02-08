class HomesController < ApplicationController
  def show
    @demo  = current_user.demo
    @user  = @demo.users.build
    @users = @demo.users.top(5)
  end
end
