class ActsController < ApplicationController
  def index
    @demo              = current_user.demo
    # TODO: the next two lines are ugly, wrote them in a big hurry
    @users             = @demo.users.order('points DESC')
    @acts              = @demo.acts.order('created_at DESC').limit(10)
    @positive_examples = Rule.positive(5)
    @negative_examples = Rule.negative(5)
    @neutral_examples  = Rule.neutral(5)
  end
end
