class Admin::ReportsController < UserBaseController
  
  def show
    @demo = Demo.find(params[:demo_id])
  end

  
end
