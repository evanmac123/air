class Admin::GoldCoinResetsController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def create
    @demo.flush_all_user_tickets
    flash[:success] = "All tickets will be cleared for this demo, it may take a few minutes to finish."
    redirect_to :back
  end
end
