class AdminsController < AdminBaseController
  def show
    @current_user = current_user
    @demos = Demo.alphabetical
    render template: 'admin/show'
  end
end
