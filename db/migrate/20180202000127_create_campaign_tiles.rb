class CreateCampaignTiles < ActiveRecord::Migration
  def change
    create_table :campaign_tiles do |t|
      t.references :tile, index: true, foreign_key: true
      t.references :campaign, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
