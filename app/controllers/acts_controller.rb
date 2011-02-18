class ActsController < ApplicationController
  def index
    @demo              = current_user.demo
    @demo_user_count   = @demo.users.count
    # TODO: the next two lines are ugly, wrote them in a big hurry
    @acts              = @demo.acts.order('created_at DESC').limit(10)

    @users             = @demo.users.order('points DESC')
  end
end
