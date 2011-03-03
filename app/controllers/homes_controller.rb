class HomesController < ApplicationController
  before_filter :redirect_to_activity, :unless => :is_mobile_device?

  def show
    @demo  = current_user.demo
    @user  = @demo.users.build
    # TODO: the next line is ugly, wrote it in a big hurry
    @users = @demo.users.order('points DESC')
  end

  private

  def redirect_to_activity
    redirect_to activity_path
  end
end
