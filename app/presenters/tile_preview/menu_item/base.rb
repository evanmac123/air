module TilePreview
  module MenuItem
    class Base
      include Rails.application.routes.url_helpers

      def to_partial_path
        'client_admin/tiles/tile_preview/menu_item'
      end

      def locals
        {}
      end
    end
  end
end
