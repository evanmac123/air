class ActsController < ApplicationController
  def index
    @acts              = Act.recent(10)
    @positive_examples = Rule.positive(5)
    @negative_examples = Rule.negative(5)
    @neutral_examples  = Rule.neutral(5)
  end
end
