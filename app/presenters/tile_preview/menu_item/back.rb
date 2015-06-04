module TilePreview
  module MenuItem
    class Back < TilePreview::MenuItem::Base
      def initialize(path)
        @path = path
      end

      def locals
        {
          item_class: "back_header",
          item_id: "back_header",
          link: @path,
          icon: "chevron-left",
          text: "Back to Tiles"
        }
      end
    end
  end
end
