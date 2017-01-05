class ChangeChannelDescriptionToText < ActiveRecord::Migration
  def up
    change_column :campaigns, :description, :text
  end
end
