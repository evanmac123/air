class Admin::UsersController < AdminBaseController
  def create
    @demo = Demo.find(params[:demo_id])
    @user = @demo.users.build(params[:user])
    @user.save

    if params[:set_claim_code]
      @user.generate_unique_claim_code!
    end
  end
end
