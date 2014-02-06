module ClientAdmin::SharesHelper
  def show_conditionally_create_tile_modal(demo = current_user.demo)
    render 'create_tile_modal', demo: demo
  end
  
  def show_conditionally_invite_users_modal(demo = current_user.demo)
    render 'invite_users_modal', demo: demo
  end
end
