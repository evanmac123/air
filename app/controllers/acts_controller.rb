class ActsController < ApplicationController
  def index
    @demo              = current_user.demo
    @ranking_in_demo   = current_user.ranking_in_demo
    @demo_user_count   = @demo.users.count
    # TODO: the next two lines are ugly, wrote them in a big hurry
    @acts              = @demo.acts.order('created_at DESC').limit(10)

    @users             = @demo.users.order('points DESC')

    # TODO: This is inefficient for large numbers of users, and should be
    # cached in the Users table instead.
    @user_rankings     = @users.inject({}) {|acc, user| acc[user] = user.ranking_in_demo; acc}
  end
end
