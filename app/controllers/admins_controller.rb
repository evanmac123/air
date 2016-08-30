class AdminsController < AdminBaseController
  def show
    @current_user = current_user
    @organizations = Organization.name_order
    render template: 'admin/show'
  end
end
