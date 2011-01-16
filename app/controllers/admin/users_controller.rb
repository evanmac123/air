class Admin::UsersController < AdminBaseController
  def create
    @demo = Demo.find(params[:demo_id])
    @user = @demo.users.build(params[:user])
    @user.save
  end
end
