class Admin::GoldCoinResetsController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def create
    @demo.flush_all_user_tickets
    flash[:success] = "All tickets cleared for this demo"
    redirect_to :back
  end
end
