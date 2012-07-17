class Admin::RafflesController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
  end

  def create
    coin_maximum = params[:coin_maximum].present? ? params[:coin_maximum].to_i : nil
    @winner = @demo.find_raffle_winner(coin_maximum)
    render :layout => false
  end
end
