class ActsController < ApplicationController
  def index
    @demo              = current_user.demo
    @users             = @demo.users.top(5)
    @acts              = @demo.acts.order('created_at DESC').limit(10)
    @positive_examples = Rule.positive(5)
    @negative_examples = Rule.negative(5)
    @neutral_examples  = Rule.neutral(5)
  end
end
