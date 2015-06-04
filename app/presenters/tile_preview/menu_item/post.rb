module TilePreview
  module MenuItem
    class Post < TilePreview::MenuItem::Base
      def initialize(tile_id)
        @tile_id = tile_id
      end

      def locals
        {
          item_class: "post_header",
          item_id: "post_header",
          link: client_admin_tile_path(@tile_id, update_status: Tile::ACTIVE, path: :via_preview_draft),
          link_options: { method: :put, id: :post },
          icon: "check",
          text: "Post"
        }
      end
    end
  end
end
