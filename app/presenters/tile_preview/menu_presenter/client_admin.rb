module TilePreview
  module MenuPresenter
    class ClientAdmin < TilePreview::MenuPresenter::Base

      private

      def calculate_menu_cells
        menu_cells = [ TilePreview::MenuItem::Back.new(client_admin_tiles_path(path: tag, show_suggestion_box: tile.suggested?)) ]

        if has_client_admin_status?
          action_button_class = case status
                                when Tile::ACTIVE
                                  TilePreview::MenuItem::Archive
                                when Tile::DRAFT
                                  TilePreview::MenuItem::Post
                                when Tile::ARCHIVE
                                  TilePreview::MenuItem::Repost
                                end

          menu_cells += [
            action_button_class.new(tile.id),
            TilePreview::MenuItem::Edit.new(tile.id, tag),
            TilePreview::MenuItem::Delete.new(tile.id, destroy_tile_message_params),
            TilePreview::MenuItem::New.new(new_client_admin_tile_path(path: tag))
          ]
        elsif user_submitted?
          menu_cells << TilePreview::IntroWrapper::ClientAdmin.new([
            TilePreview::MenuItem::Accept.new(tile.id, tag),
            TilePreview::MenuItem::Ignore.new(tile.id, tag)
          ])
        else
          menu_cells << TilePreview::MenuItem::UndoIgnore.new(tile.id, tag)
        end

        menu_cells
      end
    end
  end
end
