class Admin::PlayersController < AdminBaseController
  def create
    @demo   = Demo.find(params[:demo_id])
    @player = @demo.players.build(params[:player])
    @player.save
  end
end
