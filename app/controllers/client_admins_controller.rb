class ClientAdminsController < ClientAdminBaseController

  def show
    @board = current_user.demo
    @chart_form = BoardStatsLineChartForm.new @board, { action_type: params[:action_type] }

    render template: "client_admin/show"
  end
end
