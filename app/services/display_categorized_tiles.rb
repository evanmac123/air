class DisplayCategorizedTiles
  def initialize(user, maximum_tiles)
    @user = user
    @demo = @user.demo
    @maximum_tiles = maximum_tiles
  end

  def displayable_categorized_tiles
    result = satisfiable_tiles_categorized_to_user

    return result unless @maximum_tiles

    result[:all_tiles_displayed] = false  # default variant. it will be changed later if wrong

    length_not_completed = result[:not_completed_tiles].count
    length_completed = result[:completed_tiles].count

    if length_not_completed > @maximum_tiles
      result[:not_completed_tiles] = result[:not_completed_tiles].first(@maximum_tiles)
      result[:completed_tiles] = nil
    elsif (length_not_completed + length_completed) > @maximum_tiles
      result[:completed_tiles] = result[:completed_tiles].first(@maximum_tiles - length_not_completed)
    else
      result[:all_tiles_displayed] = true
    end
    result
  end

  protected

  def satisfiable_tiles_categorized_to_user
    {
      completed_tiles:      completed_tiles,
      not_completed_tiles:  not_completed_tiles
    }
  end

  def tiles_due_in_demo
    @demo.tiles.active
  end

  def completed_tiles
    @completed_tiles ||=  all_completed_tiles
  end

  def all_completed_tiles
    @demo.tiles.joins(:tile_completions).where(tile_completions: { user_id: @user.id, user_type: @user.class.to_s }).order("tile_completions.id DESC")
  end

  def active_completed_tiles
    all_completed_tiles.where(status: Tile::ACTIVE)
  end

  def not_completed_tiles
    completed_ids = completed_tiles.pluck(:id)

    tiles_due_in_demo.where.not(id: completed_ids).order(position: :desc)
  end
end
