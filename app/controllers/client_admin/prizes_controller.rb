class ClientAdmin::PrizesController < ClientAdminBaseController
  def index
    @demo = current_user.demo
    @raffle = @demo.raffle || @demo.raffle = Raffle.new
  end
end
