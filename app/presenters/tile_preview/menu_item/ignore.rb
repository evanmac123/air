module TilePreview
  module MenuItem
    class Ignore < TilePreview::MenuItem::Base
      def initialize(tile_id, tag)
        @tile_id = tile_id
        @tag = tag
      end

      def locals
        {
          item_class: "ignore_header",
          link: client_admin_tile_path(@tile_id, update_status: Tile::IGNORED, path: @tag),
          link_options: { method: :put },
          icon: "times",
          text: "Ignore"
        }
      end
    end
  end
end
