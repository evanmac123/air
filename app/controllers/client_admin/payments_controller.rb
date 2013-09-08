class ClientAdmin::PaymentsController < ClientAdminBaseController
  def new
    @outstanding_balances = current_user.demo.balances.outstanding.order("created_at ASC")
  end
end
