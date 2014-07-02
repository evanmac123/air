class Admin::PaidStatusesController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def create
    @demo.update_attributes(is_paid: true)
    flash[:success] = "This board is now paid"
    redirect_to :back
  end

  def destroy
    @demo.update_attributes(is_paid: false)
    flash[:success] = "This board is now free"
    redirect_to :back
  end
end
