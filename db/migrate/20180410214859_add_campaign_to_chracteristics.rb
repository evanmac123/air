class AddCampaignToChracteristics < ActiveRecord::Migration
  def change
    add_reference :characteristics, :campaign, index: true, foreign_key: true
    add_column :campaigns, :segmented, :boolean, default: false
  end
end
