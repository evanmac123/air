class ClientAdmin::ReportsController < ClientAdminBaseController

  def show
   @demo = current_user.demo
   @report = Reporting::ClientUsage.new({demo:@demo.id, start: 12.weeks.ago, interval: "week"})
   binding.pry

  end

end
