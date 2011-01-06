class PlayersController < ApplicationController
  def new
    @demo    = Demo.find_by_company_name("Alpha")
    @player  = @demo.players.build
    @players = @demo.players.top
  end
end
