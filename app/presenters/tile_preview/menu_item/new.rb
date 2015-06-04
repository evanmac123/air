module TilePreview
  module MenuItem
    class New < TilePreview::MenuItem::Base
      def initialize(tag)
        @tag = tag
      end

      def locals
        {
          item_class: "new_tile_header",
          link: new_client_admin_tile_path(path: @tag),
          icon: "plus",
          text: "New Tile"
        }
      end
    end
  end
end
