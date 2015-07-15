module TilePreview
  module MenuPresenter
    class Base
      include Rails.application.routes.url_helpers
      include ClientAdmin::TilesHelper

      attr_reader :tile, :browser
      delegate  :status,
        :has_client_admin_status?,
        :active?,
        :activated_at,
        :user_submitted?,
        to: :tile

      def initialize(tile, browser)
        @tile = tile
        @browser = browser
      end

      def status_name
        case status
        when Tile::ACTIVE
          "Posted"
        when Tile::ARCHIVE
          "Archive"
        when Tile::DRAFT
          "Draft"
        when Tile::USER_DRAFT
          "Draft"
        when Tile::USER_SUBMITTED
          "Submitted"
        when Tile::IGNORED  
          "Ignored"
        else
          ""
        end
      end

      def menu_cells
        return @menu_cells if @menu_cells.present?
        @menu_cells = calculate_menu_cells
        @menu_cells
      end

      protected

      def tag
        case status
        when Tile::ACTIVE
          :via_posted_preview
        when Tile::ARCHIVE
          :via_archived_preview
        when Tile::DRAFT
          :via_draft_preview
        when Tile::USER_SUBMITTED
          :via_preview_user_submitted
        when Tile::IGNORED
          :via_preview_ignored
        else
          ''
        end
      end
    end
  end
end
