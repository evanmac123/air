module ClientAdmin::TilesToolsSubnavHelper 
  def tiles_to_be_sent(user)
    demo = user.demo
    demo.digest_tiles(demo.tile_digest_email_sent_at).count
  end

  def block_nav? user
    demo = user.demo
    demo.non_activated? && user.show_onboarding?
  end

  def subnav_item_block params = {}
    params[:icon] ||= nil
    params[:image] ||= nil
    params[:blocked] ||= nil
    params[:link_options] ||= {}
    render partial: "client_admin/tiles/subnav_item", locals: params
  end

  def subnav_elements
    [
      {
        item_id: "explore", 
        link: explore_path, 
        icon: "rocket", 
        text: "Explore"
      },
      {
        item_id: "home_nav", 
        link: activity_path, 
        image: "airbo_logo_lightblue_square.png", 
        text: "Preview"
      },
      {
        item_id: "managing_tiles", 
        link: client_admin_tiles_path, 
        icon: "pencil", 
        text: "Edit"
      },
      {
        item_id: "share_tiles", 
        link: client_admin_share_path, 
        icon: "share-alt", 
        text: "Share"
      },
      {
        item_id: "board_activity", 
        link: client_admin_path, 
        icon: "line-chart", 
        text: "Activity"
      },
      {
        item_id: "prizes_nav", 
        link: client_admin_prizes_path, 
        icon: "trophy", 
        text: "Prizes"
      },
      {
        item_id: "users", 
        link: client_admin_users_path, 
        icon: "users", 
        text: "Users"
      },
      {
        item_id: "settings", 
        link: client_admin_board_settings_path, 
        icon: "cog", 
        text: "Settings"
      },
      {
        item_id: "admin_help", 
        link: DeskSSO.new(current_user).url, 
        icon: "question", 
        text: "Help",
        link_options: { target: "_blank" }
      }
    ]
  end

  def list_of_blocked_items
    ["Share", "Activity", "Prizes", "Users"]
  end

  def subnav_elements_with_blocked_items
    elements = subnav_elements
    elements.each do |element|
      if list_of_blocked_items.include? element[:text]
        element[:blocked] = true
      end
    end
    elements
  end

  def set_subnav_elements
    if block_nav? current_user
      subnav_elements_with_blocked_items
    else
      subnav_elements
    end
  end
end