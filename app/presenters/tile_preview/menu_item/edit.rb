module TilePreview
  module MenuItem
    class Edit < TilePreview::MenuItem::Base
      def initialize(tile_id, tag)
        @tile_id = tile_id
        @tag = tag
      end

      def locals
        {
          item_class: "edit_header",
          link: edit_client_admin_tile_path(@tile_id, path: @tag),
          icon: "pencil",
          text: "Edit"
        }
      end
    end
  end
end
