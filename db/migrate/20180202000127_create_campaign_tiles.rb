class CreateCampaignTiles < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION IF NOT EXISTS btree_gin;"
    execute "CREATE EXTENSION IF NOT EXISTS btree_gist;"

    create_table :campaign_tiles do |t|
      t.references :tile, index: true, foreign_key: true
      t.references :campaign, index: true, foreign_key: true

      t.timestamps null: false
    end
  end

  def down
    drop_table :campaign_tiles

    execute "DROP EXTENSION IF EXISTS btree_gin;"
    execute "DROP EXTENSION IF EXISTS btree_gist;"
  end
end
