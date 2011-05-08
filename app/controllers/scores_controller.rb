class ScoresController < ApplicationController
  respond_to :js, :mobile

  def index
    @demo  = current_user.demo
    @users = @demo.users.ranked.order('points DESC')
  end
end
