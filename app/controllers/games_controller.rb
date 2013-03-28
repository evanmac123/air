class GamesController < ApplicationController
  skip_before_filter :authorize
  layout 'external' 
  def new
  end
end
