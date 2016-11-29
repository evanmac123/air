class Admin::TileFeaturesController < AdminBaseController
  def index
    @tile_features = TileFeature.scoped
  end

  def create
    @tile_feature = TileFeature.new(tile_feature_ar_params)
    if @tile_feature.save
      @tile_feature.dispatch_redis_updates(tile_feature_redis_params)
      redirect_to admin_tile_features_path
    else
      render :new
    end
  end

  def update
    TileFeature.dispatch(tile_feature_params)
  end

  def new
    @tile_feature = TileFeature.new
  end

  private

    def tile_feature_ar_params
      params.require(:tile_feature).permit(:name, :rank, :active)
    end

    def tile_feature_redis_params
      params.require(:redis).permit(:custom_icon_url, :text_color, :header_copy, :background_color, :tile_ids)
    end
end
