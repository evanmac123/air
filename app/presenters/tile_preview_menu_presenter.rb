class TilePreviewMenuPresenter
  include Rails.application.routes.url_helpers
  include ClientAdmin::TilesHelper

  attr_reader :tile
  delegate  :status,
            :has_client_admin_status?,
            :active?,
            :activated_at,
            :user_submitted?,
            to: :tile

  def initialize(tile)
    @tile = tile
  end

  def status_name
    case status
    when Tile::ACTIVE
      "Posted"
    when Tile::ARCHIVE
      "Archive"
    when Tile::DRAFT
      "Draft"
    when Tile::USER_DRAFT
      "Draft"
    when Tile::USER_SUBMITTED
      "Submitted"
    when Tile::IGNORED  
      "Ignored"
    else
      ""
    end
  end

  def menu_item_path
    'client_admin/tiles/tile_preview/menu_item'
  end
  #
  # => Menu Items
  #
  def back_btn_params
    {
      item_class: "back_header",
      item_id: "back_header",
      link: client_admin_tiles_path(path: tag, show_suggestion_box: tile.suggested?),
      icon: "chevron-left",
      text: "Back to Tiles"
    }
  end

  def action_btn_params
    case status
    when Tile::ACTIVE
      archive_btn_params
    when Tile::DRAFT
      post_btn_params
    when Tile::ARCHIVE
      repost_btn_params
    else
      {}
    end
  end

  def archive_btn_params
    {
      item_class: "post_header",
      item_id: "archive_header",
      link: client_admin_tile_path(tile, update_status: Tile::ARCHIVE, path: :via_preview_post),
      link_options: { method: :put, id: :archive },
      icon: "archive",
      text: "Archive"
    }
  end

  def post_btn_params
    {
      item_class: "post_header",
      item_id: "post_header",
      link: client_admin_tile_path(tile, update_status: Tile::ACTIVE, path: :via_preview_draft),
      link_options: { method: :put, id: :post },
      icon: "check",
      text: "Post"
    }
  end

  def edit_btn_params
    {
      item_class: "edit_header",
      link: edit_client_admin_tile_path(tile, path: tag),
      icon: "pencil",
      text: "Edit"
    }
  end

  def repost_btn_params
    {
      item_class: "post_header",
      item_id: "post_header",
      link: client_admin_tile_path(tile, update_status: Tile::ACTIVE, path: :via_preview_archive),
      link_options: { method: :put, id: :post },
      icon: "check",
      text: "Repost"
    }
  end

  def delete_btn_params
    {
      item_class: "destroy_header",
      link: client_admin_tile_path(tile, page: 'Large Tile Preview'),
      link_options: { method: :delete, data: { confirm: destroy_tile_message_params } },
      icon: "trash",
      text: "Delete"
    }
  end

  def new_tile_btn_params
    {
      item_class: "new_tile_header",
      link: new_client_admin_tile_path(path: tag),
      icon: "plus",
      text: "New Tile"
    }
  end

  def accept_btn_params
    {
      item_class: "accept_header",
      link: client_admin_tile_path(tile, update_status: Tile::DRAFT, path: tag),
      link_options: { method: :put },
      icon: "check",
      text: "Accept"
    }
  end

  def ignore_btn_params
    {
      item_class: "ignore_header",
      link: client_admin_tile_path(tile, update_status: Tile::IGNORED, path: @tag),
      link_options: { method: :put },
      icon: "times",
      text: "Ignore"
    }
  end

  def undo_ignore_btn_params
    {
      item_class: "undo_ignore_header",
      link: client_admin_tile_path(tile, update_status: Tile::USER_SUBMITTED, path: @tag),
      link_options: { method: :put },
      icon: "undo",
      text: "Undo Ignore"
    }
  end

  protected

  def tag
    case status
    when Tile::ACTIVE
      :via_posted_preview
    when Tile::ARCHIVE
      :via_archived_preview
    when Tile::DRAFT
      :via_draft_preview
    when Tile::USER_SUBMITTED
      :via_preview_user_submitted
    when Tile::IGNORED
      :via_preview_ignored
    else
      ''
    end
  end
end
