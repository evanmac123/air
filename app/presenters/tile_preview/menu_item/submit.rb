module TilePreview
  module MenuItem
    class Submit < TilePreview::MenuItem::Base
      def initialize(tile_id)
        @tile_id = tile_id
      end

      def locals
        {
          item_class: "submit_header",
          item_id: "submit_header",
          link: suggested_tile_path(@tile_id, update_status: Tile::USER_SUBMITTED),
          link_options: {method: :put},
          icon: "check",
          text: "Submit"
        }
      end
    end
  end
end
