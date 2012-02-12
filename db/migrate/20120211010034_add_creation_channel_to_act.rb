class AddCreationChannelToAct < ActiveRecord::Migration
  def self.up
    add_column :acts, :creation_channel, :string, :default => ''
    execute "UPDATE acts SET creation_channel = ''"
    change_column :acts, :creation_channel, :string, :default => '', :null => false
  end

  def self.down
    remove_column :acts, :creation_channel
  end
end
