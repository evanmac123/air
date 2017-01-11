class AddShowRelatedContentLinkToTileFeature < ActiveRecord::Migration
  def change
    add_column :tile_features, :show_related_content_link, :boolean, default: false
  end
end
