class GamesController < ApplicationController
  skip_before_filter :authorize
  layout 'game' 
  def new
  end
end
