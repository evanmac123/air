class ScoresController < ApplicationController
  def index
    @demo  = current_user.demo
    @users = @demo.users.order('points DESC')
  end
end
