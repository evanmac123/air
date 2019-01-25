# frozen_string_literal: true

class TilesToolsSubnavPresenter
  include AirboLearningHelper
  include Rails.application.routes.url_helpers

  attr_reader :current_user

  delegate    :has_tiles_tools_subnav?,
              :demo,
              to: :current_user

  def initialize(user)
    @current_user = user
  end

  def items_with_corrected_params
    subnav_elements.each do |item_params|
      yield correct_params(item_params)
    end
  end

  def show_subnav?
    has_tiles_tools_subnav?
  end

  def side_nav_id
    "tile_manager_nav"
  end

  def side_nav_class
    "js-client-admin-side-nav"
  end

  private

    def correct_params(params = {})
      params[:icon] ||= nil
      params[:image] ||= nil
      params[:blocked] ||= nil
      params[:link_options] ||= {}
      params
    end

    def tiles_to_be_sent
      demo.digest_tiles.count
    end

    def subnav_elements
      nav = []

      nav.tap do |els|

        els.concat(
          [
            {
              item_id: "explore",
              link: explore_path,
              icon: "rocket",
              text: "Explore",
              has_notification: false
            },
            {
              item_id: "managing_tiles",
              link: client_admin_tiles_path,
              icon: "pencil",
              text: "Edit",
              has_notification: false
            },
            {
              item_id: "home_nav",
              link: activity_path,
              image: "airbo_logo_lightblue_square.png",
              text: "Preview",
              has_notification: false
            },
            {
              item_id: "share_tiles",
              link: client_admin_share_path,
              icon: "share-alt",
              text: "Share",
              has_notification: true,
              notification_content: tiles_to_be_sent
            },
            {
              item_id: "board_activity",
              link: client_admin_reports_path,
              icon: "line-chart",
              text: "Reports",
              has_notification: current_user.has_tile_email_report_notification?,
              notification_content: current_user.get_tile_email_report_notification_content
            },
            {
              item_id: "prizes_nav",
              link: client_admin_prizes_path,
              icon: "trophy",
              text: "Prizes",
              has_notification: false
            },
            {
              item_id: "users",
              link: client_admin_users_path,
              icon: "users",
              text: "Users",
              has_notification: false
            },
            {
              item_id: "settings",
              link: client_admin_board_settings_path,
              icon: "cog",
              text: "Setup",
              has_notification: false
            },
            {
              item_id: "admin_help",
              link: airbo_learning_url,
              icon: "question",
              text: "Help",
              has_notification: false,
              link_options: { target: "_blank" }
            }
          ]
        )
      end
    end
end
