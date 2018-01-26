# frozen_string_literal: true

class TileCopier
  EXPLORE_PING = "Explore Page"
  OWN_BOARD_PING = "Self Created - Duplicated"
  TEMPLATE_PING = "Initial Board Setup"

  attr_reader :copying_user, :tile, :copy

  def initialize(new_demo, tile, copying_user = nil)
    @copying_user = copying_user
    @tile = tile
    @copy = new_demo.tiles.new
  end

  def copy_tile_from_explore
    copy_tile(status: Tile::DRAFT, creation_source: :explore_created, ping_source: EXPLORE_PING)

    deliver_tile_copied_notification
    tile.increment!(:copy_count)
    copy
  end

  def copy_from_own_board
    copy_tile(status: Tile::DRAFT, creation_source: :client_admin_created, ping_source: OWN_BOARD_PING)
  end

  def copy_from_template
    copy_tile(status: Tile::ACTIVE, creation_source: :client_admin_created, ping_source: TEMPLATE_PING)
  end

  private

    def copy_tile(status:, creation_source:, ping_source:)
      copy_tile_data
      set_new_data_for_copy(status: status, creation_source: creation_source)
      ping_tile_created(ping_source)

      # NOTE copy attachments after save so attachment has an id
      copy.save
      tile.copy_s3_attachments_to(copy)

      copy.tap(&:save)
    end

    def ping_tile_created(copy_source)
      TrackEvent.ping("Tile - New", { tile_source: copy_source }, copying_user)
    end

    def deliver_tile_copied_notification
      Mailer.notify_creator_for_social_interaction(tile, copying_user, "copied").deliver_later
    end

    def copy_tile_data
      [
        "correct_answer_index",
        "headline",
        "multiple_choice_answers",
        "points",
        "question",
        "supporting_content",
        "image",
        "embed_video",
        "thumbnail",
        "question_type",
        "question_subtype",
        "allow_free_response",
        "is_anonymous",
      ].each do |field_to_copy|
        copy.send("#{field_to_copy}=", tile.send(field_to_copy))
      end
    end

    def set_new_data_for_copy(status:, creation_source:)
      copy.assign_attributes(
        status: status,
        original_creator: tile.creator || tile.original_creator,
        original_created_at: tile.created_at || tile.original_created_at,
        creator: copying_user,
        remote_media_url: tile.image.url(:original, timestamp: false),
        media_source: "tile-copy",
        creation_source: creation_source
      )
    end
end
