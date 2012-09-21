class RemoveDescriptionsFromTiles < ActiveRecord::Migration
  def up
    remove_column :tiles, :short_description
    remove_column :tiles, :long_description
  end

  def down
    add_column :tiles, :short_description, :text, :default => ''
    add_column :tiles, :long_description, :text, :default => ''
  end
end
