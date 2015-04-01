class TilePreviewsNullIntrosPresenter < TilePreviewIntrosPresenter
  def initialize
  end

  def data_for(key)
    {}
  end

  def any_active?
    false
  end
end
