class AdminsController < AdminBaseController
  def show
    @demos = Demo.alphabetical
    render :template => 'admin/show'
  end
end
