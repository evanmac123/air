module TilePreview
  module MenuItem
    class New < TilePreview::MenuItem::Base
      def initialize(path)
        @path = path
      end

      def locals
        {
          item_class: "new_tile_header",
          link: @path,
          icon: "plus",
          text: "New Tile",
          item_id: "add_new_tile"
        }
      end
    end
  end
end
