class ClientAdmin::ReportsController < ClientAdminBaseController
  def show
    @board = current_user.demo
  end
end
