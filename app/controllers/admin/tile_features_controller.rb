class Admin::TileFeaturesController < AdminBaseController
  def index
    @tile_features = TileFeature.scoped
  end
end
