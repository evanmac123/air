module ClientAdmin::SharesHelper
  def show_conditionally_create_tile_modal(demo = current_user.demo)
    render 'create_tile_modal', demo: demo if current_user.demo.active_tiles.count < 1
  end
  
  def show_conditionally_invite_users_modal(demo = current_user.demo)
    render 'invite_users_modal', demo: demo, auto_show: current_user.show_invite_users_modal? && 
      demo.active_tiles.count > 0
  end
end
