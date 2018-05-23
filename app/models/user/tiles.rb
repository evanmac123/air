# frozen_string_literal: true

module User::Tiles
  def tiles_to_complete_in_demo
    return [] unless demo

    ids_completed = tile_completions.pluck(:tile_id)
    segmented_tiles_for_user.where.not(id: ids_completed).ordered_by_position
  end

  def segmented_tiles_for_user
    # TODO: Decouple tiles.active from ordered_by_position
    demo.tiles.segmented_for_user(self).where(status: Tile::ACTIVE)
  end

  def completed_tiles_in_demo
    return [] unless demo

    demo.tiles.joins(:tile_completions).merge(tile_completions).uniq
  end

  def active_tiles_in_demo
    # TODO: Decouple tiles.active from ordered_by_position
    demo.tiles.where(status: Tile::ACTIVE)
  end

  def not_show_all_completed_tiles_in_progress
    User::TileProgressCalculator.new(self).not_show_all_completed_tiles_in_progress
  end

  def available_tiles_for_points_progress
    User::TileProgressCalculator.new(self).available_tiles_for_points_progress
  end

  def completed_tiles_for_points_progress
    User::TileProgressCalculator.new(self).completed_tiles_for_points_progress
  end

  def reset_tiles(demo = nil)
    demo ||= self.demo
    demo.tile_completions.select([:id, :tile_id]).where(user_id: self.id).destroy_all
  end
end
