class AddDataToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :instructions, :text
    add_column :campaigns, :duration, :integer
    add_column :campaigns, :sources, :text
  end
end
