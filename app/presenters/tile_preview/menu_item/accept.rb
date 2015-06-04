module TilePreview
  module MenuItem
    class Accept < TilePreview::MenuItem::Base
      def initialize(tile_id, tag)
        @tile_id = tile_id
        @tag = tag
      end

      def locals
        {
          item_class: "accept_header",
          link: client_admin_tile_path(@tile_id, update_status: Tile::DRAFT, path: @tag),
          link_options: { method: :put },
          icon: "check",
          text: "Accept"
        }
      end
    end
  end
end
