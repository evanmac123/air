class ClientAdmin::ExploreNewsController < ClientAdminBaseController  
  before_filter :find_current_user_demo

  def show
  end

  protected

  def find_current_user_demo
    @demo = current_user.demo
  end
end
