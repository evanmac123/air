module TileFeaturesHelper
  def show_feature_related_content_link?(feature)
    feature.show_related_content_link  && feature.slug != params[:id]
  end
end
