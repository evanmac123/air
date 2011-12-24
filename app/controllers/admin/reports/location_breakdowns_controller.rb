class Admin::Reports::LocationBreakdownsController < AdminBaseController
  def show
    @demo = Demo.find(params[:demo_id])
    @location_breakdown = @demo.location_breakdown
  end
end
