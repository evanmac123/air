class TileCopier
  EXPLORE_SOURCE = "Explore Page"
  OWN_BOARD_SOURCE = "Self Created - Duplicated"

  attr_reader :new_demo, :copying_user, :tile, :copy
  def initialize(new_demo, tile, copying_user = nil)
    @new_demo = new_demo
    @copying_user = copying_user
    @tile = tile
    @copy = tile.class.new
  end

  def copy_tile_from_explore
    copy_tile
    copy.creation_source = :explore_created
    ping_tile_created(EXPLORE_SOURCE)
    deliver_tile_copied_notification
    tile.increment!(:copy_count)

    copy.tap(&:save)
  end

  def copy_from_own_board(status = Tile::DRAFT, tile_source = OWN_BOARD_SOURCE)
    copy_tile(status)
    ping_tile_created(tile_source)

    copy.tap(&:save)
  end


  private

    def copy_tile(status = Tile::DRAFT)
      copy_tile_data
      set_new_data_for_copy(status)
    end

    def ping_tile_created(copy_source)
      TrackEvent.ping('Tile - New', { tile_source: copy_source }, copying_user )
    end

    def deliver_tile_copied_notification
      Mailer.delay_mail(:notify_creator_for_social_interaction, tile, copying_user, 'copied')
    end

    def copy_tile_data
      [
        "correct_answer_index",
        "headline",
        "link_address",
        "multiple_choice_answers",
        "points",
        "question",
        "supporting_content",
        "image",
        "embed_video",
        "thumbnail",
        "use_old_line_break_css",
        "question_type",
        "question_subtype",
        "allow_free_response",
        "is_anonymous",
        "file_attachments"
      ].each do |field_to_copy|
        copy.send("#{field_to_copy}=", tile.send(field_to_copy))
      end
    end

    def set_new_data_for_copy(status)
      copy.status = status
      copy.original_creator = tile.creator || tile.original_creator
      copy.original_created_at = tile.created_at || tile.original_created_at
      copy.demo = new_demo
      copy.creator = copying_user
      copy.position = copy.find_new_first_position
      copy.remote_media_url = tile.image.url(:original)
      copy.media_source = "tile-copy"
      copy.is_cloned = true
    end
end
