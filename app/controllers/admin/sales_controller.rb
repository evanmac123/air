class Admin::SalesController < AdminBaseController
  def show
    @dashboard = SalesDashboardService.new
  end
end
