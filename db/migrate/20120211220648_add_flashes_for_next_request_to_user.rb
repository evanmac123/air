class AddFlashesForNextRequestToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :flashes_for_next_request, :text
  end

  def self.down
    remove_column :users, :flashes_for_next_request
  end
end
