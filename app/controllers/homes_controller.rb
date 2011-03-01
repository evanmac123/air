class HomesController < ApplicationController
  before_filter :mobile_if_mobile_device

  def show
    @demo  = current_user.demo
    @user  = @demo.users.build
    # TODO: the next line is ugly, wrote it in a big hurry
    @users = @demo.users.order('points DESC')
  end
end
