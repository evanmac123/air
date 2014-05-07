class ClientAdmin::ExploreNewsController < ClientAdminBaseController  
  def show
    @demo = current_user.demo
  end
end
