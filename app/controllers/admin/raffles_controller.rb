class Admin::RafflesController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
  end

  def create
    @winner = @demo.find_raffle_winner
    render :layout => false
  end
end
