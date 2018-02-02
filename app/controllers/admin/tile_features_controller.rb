# frozen_string_literal: true

class Admin::TileFeaturesController < AdminBaseController
  def index
    @tile_features = TileFeature.order(:name)
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
    @tile_features = TileFeature.all
    @tile_feature = TileFeature.find_by(slug: params[:id])
    if @tile_feature.update_attributes(tile_feature_ar_params)
      @tile_feature.dispatch_redis_updates(tile_feature_redis_params)
    else
      flash[:failure] = @tile_feature.errors.full_messages
    end

    redirect_to admin_tile_features_path
  end

  def new
    @tile_feature = TileFeature.new
  end

  private

    def tile_feature_ar_params
      params.require(:tile_feature).permit(:name, :rank, :active, :show_related_content_link)
    end

    def tile_feature_redis_params
      params.require(:redis).permit(:custom_icon_url, :text_color, :header_copy, :background_color, :tile_ids, :channels)
    end
end
