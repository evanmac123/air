class AddCommandToMoreInfoRequest < ActiveRecord::Migration
  def self.up
    add_column :more_info_requests, :command, :string
  end

  def self.down
    remove_column :more_info_requests, :command
  end
end
