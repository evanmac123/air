class DropCampaignTilesTable < ActiveRecord::Migration
  def change
    drop_table :campaign_tiles
  end
end
