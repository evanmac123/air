module TilePreview
  module MenuItem
    class Archive < TilePreview::MenuItem::Base
      def initialize(tile_id)
        @tile_id = tile_id
      end

      def locals
        {
          item_class: "post_header",
          item_id: "archive_header",
          link: client_admin_tile_path(@tile_id, update_status: Tile::ARCHIVE, path: :via_preview_post),
          link_options: { method: :put, id: :archive },
          icon: "archive",
          text: "Archive"
        }
      end
    end
  end
end
