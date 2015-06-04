module TilePreview
  module MenuItem
    class UndoIgnore < TilePreview::MenuItem::Base
      def initialize(tile_id, tag)
        @tile_id = tile_id
        @tag = tag
      end

      def locals
        {
          item_class: "undo_ignore_header",
          link: client_admin_tile_path(@tile_id, update_status: Tile::USER_SUBMITTED, path: @tag),
          link_options: { method: :put },
          icon: "undo",
          text: "Undo Ignore"
        }
      end
    end
  end
end
