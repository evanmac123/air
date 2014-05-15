class AddIndicesToMakeExplorePageNotSuck < ActiveRecord::Migration
  def up
    execute "commit" # hack to allow us to use CREATE_INDEX_CONCURRENTLY
    execute "CREATE INDEX CONCURRENTLY index_user_tile_likes_on_tile_id ON user_tile_likes USING btree(tile_id)"
  end

  def down
    remove_index :user_tile_likes, :tile_id
  end
end
