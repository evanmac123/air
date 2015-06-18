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
          text: "New Tile"
        }
      end
    end
  end
end
