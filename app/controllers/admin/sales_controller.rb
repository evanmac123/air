class Admin::SalesController < AdminBaseController
  def show
    @dashboard = SalesDashboardService.new(current_user)
  end
end
