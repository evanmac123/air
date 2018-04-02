class AddCampaignToTile < ActiveRecord::Migration
  def change
    add_reference :tiles, :campaign, index: true, foreign_key: true
  end
end
