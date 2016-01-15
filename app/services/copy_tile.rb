class CopyTile
  def initialize(new_demo, copying_user)
    @new_demo = new_demo
    @copying_user = copying_user
  end

  def copy_active_tiles_from_demo(demo)
    demo.active_tiles.reverse.each do |tile|
      copy_tile(tile, false)
    end
  end

  def copy_tile(tile, mark_tile_as_copied = true)
    @tile = tile
    @copy =tile.class.new

    copy_tile_data
    set_new_data_for_copy
    if mark_tile_as_copied
      mark_tile_as_copied_by_user
      @tile.save
    end
    @copy.remote_media_url= @tile.image.url(:original)
    @copy.save
    @copy
  end

  protected

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
      "thumbnail"
    ].each do |field_to_copy|
      @copy.send("#{field_to_copy}=", @tile.send(field_to_copy))
    end
  end

  def set_new_data_for_copy
    @copy.status = Tile::DRAFT
    @copy.original_creator = @tile.creator || @tile.original_creator
    @copy.original_created_at = @tile.created_at || @tile.original_created_at
    @copy.demo = @new_demo
    @copy.creator = @copying_user
    @copy.position = @copy.find_new_first_position
  end

  def mark_tile_as_copied_by_user
    @tile.user_tile_copies.build(user_id: @copying_user.id)
  end
end
