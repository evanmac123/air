class AddDurationDescriptionToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :duration_description, :string
  end
end
