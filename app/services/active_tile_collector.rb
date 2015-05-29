class ActiveTileCollector 
  def	initialize board, beg_date, end_date
    @beg_date = beg_date 
    @end_date = end_date 
    @board = board 
  end

  def collect
    viewings.map(&:tile) | completions.map(&:tile)
  end

  private

  def has_tile_activity?
    viewings.any? || completions.any?
  end

  def viewings 
    @viewings ||=@board.tile_viewings.for_period(@beg_date, @end_date)
  end

  def completions 
    @completions ||= @board.tile_completions.for_period(@beg_date, @end_date)
  end

end
