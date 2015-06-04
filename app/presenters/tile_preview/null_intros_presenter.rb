module TilePreview
  class NullIntrosPresenter < TilePreview::IntrosPresenter
    def initialize
    end

    def data_for(key)
      {}
    end

    def any_active?
      false
    end
  end
end
