module TilePreview
  module MenuItem
    class Unsubmit < TilePreview::MenuItem::Base
      def initialize(tile_id)
        @tile_id = tile_id
      end

      def locals
        {
          item_class: "submit_header",
          item_id: "unsubmit_header",
          link: suggested_tile_path(@tile_id, update_status: Tile::USER_DRAFT, method: :put),
          link_options: {method: :put},
          icon: "rotate-left",
          text: "Unsubmit"
        }
      end
    end
  end
end
