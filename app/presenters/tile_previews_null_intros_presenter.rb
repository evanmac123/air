require Rails.root.join('app/presenters/tile_previews_intros_presenter')

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
