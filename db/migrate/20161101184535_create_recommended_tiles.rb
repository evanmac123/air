class CreateRecommendedTiles < ActiveRecord::Migration
  def change
    create_table :recommended_tiles do |t|
      t.integer :tile_id
      t.integer :user_id
      t.integer :demo_id
      t.integer :topic_id
      t.string :action_taken

      t.timestamps
    end
  end
end
