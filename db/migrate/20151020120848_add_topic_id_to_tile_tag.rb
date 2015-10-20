class AddTopicIdToTileTag < ActiveRecord::Migration
  def change
    add_column :tile_tags, :topic_id, :integer
    add_index  :tile_tags, :topic_id
  end
end
