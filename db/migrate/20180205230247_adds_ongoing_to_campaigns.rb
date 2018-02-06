class AddsOngoingToCampaigns < ActiveRecord::Migration
  def up
    remove_attachment :campaigns, :cover_image
    remove_column :campaigns, :instructions
    remove_column :campaigns, :duration
    remove_column :campaigns, :sources
    remove_column :campaigns, :duration_description

    add_column :campaigns, :ongoing, :boolean, default: false
    add_column :campaigns, :icon_link, :string
  end

  def down
    add_attachment :campaigns, :cover_image
    add_column :campaigns, :instructions, :text
    add_column :campaigns, :duration, :integer
    add_column :campaigns, :sources, :text
    add_column :campaigns, :duration_description, :text

    remove_column :campaigns, :ongoing
    remove_column :campaigns, :icon_link
  end
end
