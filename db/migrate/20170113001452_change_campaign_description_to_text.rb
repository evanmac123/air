class ChangeCampaignDescriptionToText < ActiveRecord::Migration
  def up
    change_column :channels, :description, :text
  end
end
