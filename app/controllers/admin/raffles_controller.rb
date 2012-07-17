class Admin::RafflesController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
    load_characteristics(@demo)
  end

  def create
    coin_maximum = params[:coin_maximum].present? ? params[:coin_maximum].to_i : nil
    @winner = @demo.find_raffle_winner(current_user.segmentation_results.try(:found_user_ids), coin_maximum)
    render :layout => false
  end
end
