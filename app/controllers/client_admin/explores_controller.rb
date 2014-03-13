class ClientAdmin::ExploresController < ClientAdminBaseController  
  def show
    @demo = current_user.demo
    @new_client_admin = @demo.tiles.empty?
  end
end