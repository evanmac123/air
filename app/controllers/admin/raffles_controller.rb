class Admin::RafflesController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
    load_characteristics(@demo)
  end

  def create
    ticket_maximum = params[:ticket_maximum].present? ? params[:ticket_maximum].to_i : nil
    @winner = @demo.find_raffle_winner(current_user.segmentation_results.try(:found_user_ids), ticket_maximum)
    render :layout => false
  end
end
