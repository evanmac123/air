module TilePreview
  module MenuItem
    class Delete < TilePreview::MenuItem::Base
      def initialize(tile_id, destroy_tile_message_params)
        @tile_id = tile_id
        @destroy_tile_message_params = destroy_tile_message_params
      end

      def locals
        {
          item_class: "destroy_header",
          link: client_admin_tile_path(@tile_id, page: 'Large Tile Preview'),
          link_options: { method: :delete, data: { confirm: @destroy_tile_message_params } },
          icon: "trash",
          text: "Delete"
        }
      end
    end
  end
end
