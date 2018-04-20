class AddCampaignToChracteristics < ActiveRecord::Migration
  def change
    add_reference :campaigns, :characteristic, index: true, foreign_key: true
  end
end
