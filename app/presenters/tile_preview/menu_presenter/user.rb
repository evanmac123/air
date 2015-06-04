module TilePreview
  module MenuPresenter
    class User < TilePreview::MenuPresenter::Base
      private

      def calculate_menu_cells
        menu_cells = [ TilePreview::MenuItem::Back.new(suggested_tiles_path) ]

        if tile.user_draft?
          menu_cells << TilePreview::MenuItem::Submit.new(tile.id)
        elsif tile.user_submitted?
          menu_cells << TilePreview::MenuItem::Unsubmit.new(tile.id)
        end

        menu_cells
      end
    end
  end
end
