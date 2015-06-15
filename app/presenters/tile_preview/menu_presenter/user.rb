module TilePreview
  module MenuPresenter
    class User < TilePreview::MenuPresenter::Base
      private

      def calculate_menu_cells
        [
          TilePreview::MenuItem::Back.new(suggested_tiles_path),
          TilePreview::MenuItem::New.new(nil)
        ]
      end
    end
  end
end
