class ActsController < ApplicationController
  def index
    @acts = Act.recent
  end
end
