class AddOrgShareToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :private_explore, :boolean, default: false
    add_column :campaigns, :public_explore, :boolean, default: false
  end
end
