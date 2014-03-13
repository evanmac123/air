class ClientAdmin::ExploresController < ClientAdminBaseController  
  def show
    @demo = current_user.demo
  end
end
