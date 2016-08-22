class TilesToolsSubnavPresenter
  include Rails.application.routes.url_helpers

  attr_reader :current_user

  delegate    :has_tiles_tools_subnav?,
              :demo,
              to: :current_user

  def initialize(user)
    @current_user = if user.is_parent_board_user?
                      @is_parent_board_user = true
                      user.original_user
                    else
                      user
                    end
  end

  def items_with_corrected_params
    elements = set_subnav_elements.reject { |el|
      el[:item_id] == "explore" if demo.explore_disabled?
    }

    elements.each do |item_params|
      yield correct_params(item_params)
    end
  end

  def show_subnav?
    has_tiles_tools_subnav?
  end

  def tile_manager_nav_class
    if @is_parent_board_user
      'parent_board'
    else
      ''
    end
  end

  private

  def show_explore?
    current_user.is_site_admin? || EXPLORE_ENABLED == "true"
  end

  def show_library?
    current_user.is_site_admin? || LIBRARY_ENABLED == "true"
  end

  def set_subnav_elements
    if block_nav?
      subnav_elements_with_blocked_items
    else
      subnav_elements
    end

  end


  def correct_params params = {}
    params[:icon] ||= nil
    params[:image] ||= nil
    params[:blocked] ||= nil
    params[:link_options] ||= {}
    params
  end

  def block_nav?
    demo.non_activated? && current_user.show_onboarding?
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

  def subnav_elements
     nav = []

    nav.tap do |els|
      els.concat([{
        item_id: "explore",
        link: explore_path,
        icon: "rocket",
        text: "Explore"
      }]) if show_explore?

      els.concat([{
        item_id: "library",
        link: client_admin_stock_boards_path,
        icon: "bank",
        text: "Library"
      }]) if show_library?

      els.concat(
        [{
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
          link: support_path,
          icon: "question",
          text: "Help",
          link_options: { target: "_blank" }
        }]
      )
    end
  end

  def list_of_blocked_items
   ["Share", "Activity", "Prizes", "Users"]
  end
end
