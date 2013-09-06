class ClientAdmin::PaymentsController < ClientAdminBaseController
  def index
  end

  def create
    render inline: 'ok'
  end
end
