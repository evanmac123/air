class Admin::PaidStatusesController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def create
    @demo.update_attributes(is_paid: true)
    flash[:success] = "This board is now paid"
    board_type_ping "Paid"
    redirect_to :back
  end

  def destroy
    @demo.update_attributes(is_paid: false)
    flash[:success] = "This board is now free"
    board_type_ping "Free"
    redirect_to :back
  end

  protected

  def board_type_ping type
    ping 'Board Type', {type: type}, current_user
  end
end
