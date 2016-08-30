class AdminsController < AdminBaseController
  def show
    @current_user = current_user
    @organizations = Organization.all
    @demos = Demo.list
    render template: 'admin/show'
  end
end
